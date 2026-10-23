import 'package:kaj_ache/core/error/api_error.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/success_model.dart';
import '../../home/models/category_response_model.dart';
import '../../home/repository/home_repository.dart';
import '../../main/controller/main_controller.dart';
import '../model/instant_service_model.dart';
import '../repository/instant_service_repository.dart';

/// Controller for the create/post form of an Instant Service.
///
/// Mirrors `lib/features/booking/controller/booking_controller.dart` but the
/// job is simpler — a single-page form with title, details, a price range
/// (priceMin/priceMax) instead of a single max budget, and an optional
/// schedule. Payment does NOT happen here — bidding opens immediately and
/// the fee is paid only after the customer selects a winning bid.
class InstantServiceController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final InstantServiceRepository repository = InstantServiceRepository();
  final ImagePicker _imagePicker = ImagePicker();

  final isLoading = false.obs;

  /// API limits (see API_Server src/utils/jobRequest.js TEXT_LIMITS).
  static const int titleMaxLength = 150;
  static const int detailsMaxLength = 5000;
  static const int addressMaxLength = 300;
  static const int maxAmount = 10000000;

  /// Optional category, like the website's post form.
  final categories = <CategoryModel>[].obs;
  final selectedCategoryId = RxnString();

  final titleController = TextEditingController();
  final detailsEditorController = HtmlEditorController();
  final priceMinController = TextEditingController();
  final priceMaxController = TextEditingController();
  final addressController = TextEditingController();
  final districtController = TextEditingController();
  final dateController = TextEditingController();

  final RxnDouble pickedLat = RxnDouble();
  final RxnDouble pickedLng = RxnDouble();

  /// Optional cover photo submitted alongside the post.
  final pickedImage = Rxn<File>();

  RxnString selectedTime = RxnString();

  final timeSlots = const [
    '09:00 AM',
    '11:00 AM',
    '01:00 PM',
    '03:00 PM',
    '05:00 PM',
    '07:00 PM',
  ];

  @override
  void onInit() {
    super.onInit();

    // Block technicians from posting instant service requests.
    final mainCtrl = Get.find<MainController>();
    if (mainCtrl.isServiceProvider) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          TKeys.error.tr,
          TKeys.techniciansCannotPost.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return;
    }

    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      categories.assignAll(await HomeRepository().getCategories());
    } catch (_) {
      // Non-fatal: the category is optional
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    priceMinController.dispose();
    priceMaxController.dispose();
    addressController.dispose();
    districtController.dispose();
    dateController.dispose();
    super.onClose();
  }

  /// Returns true when the HTML editor's output is effectively empty (some
  /// editors return an empty wrapper like `<p><br></p>` for a blank editor).
  bool _isDetailsHtmlEmpty(String html) {
    final stripped = html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', '')
        .trim();
    return stripped.isEmpty;
  }

  Future<void> pickCoverImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      pickedImage.value = File(picked.path);
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      dateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      update();
    }
  }

  Future<void> submitInstantService() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final priceMin = int.tryParse(priceMinController.text.trim()) ?? 0;
    final priceMax = int.tryParse(priceMaxController.text.trim()) ?? 0;

    if (priceMin > priceMax) {
      Get.snackbar(
        TKeys.validation.tr,
        TKeys.invalidPriceRangeError.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade700,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
      return;
    }

    isLoading.value = true;
    final detailsHtml = (await detailsEditorController.getText()).trim();
    final detailsError = _isDetailsHtmlEmpty(detailsHtml)
        ? TKeys.describeProblemError.tr
        : detailsHtml.length > detailsMaxLength
            ? TKeys.detailsTooLong.trParams({'max': '$detailsMaxLength'})
            : null;
    if (detailsError != null) {
      isLoading.value = false;
      Get.snackbar(
        TKeys.validation.tr,
        detailsError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade700,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
      return;
    }

    try {

      /// CREATE INSTANT SERVICE (no payment yet — bidding opens right away;
      /// payment happens after the client selects a winning bid).
      await repository.createInstantService(
        title: titleController.text.trim(),
        details: detailsHtml,
        category: selectedCategoryId.value,
        priceMin: priceMin,
        priceMax: priceMax,
        location: InstantServiceLocationModel(
          address: addressController.text.trim(),
          // Empty city is omitted; the backend defaults it to Dhaka
          city: '',
          district: districtController.text.trim(),
          lat: pickedLat.value,
          lng: pickedLng.value,
        ),
        schedule: InstantServiceScheduleModel(
          date: dateController.text.trim(),
          time: selectedTime.value ?? '',
        ),
        imageFile: pickedImage.value,
      );

      await Get.dialog(
        SuccessModal(
          title: TKeys.instantServiceSubmitted.tr,
          message: TKeys.instantServiceSubmittedMsg.tr,
          yesText: TKeys.myInstantServices.tr,
          onYes: () {
            Get.back();
            Get.until((r) => r.settings.name == AppRoutes.main);
            Get.toNamed(AppRoutes.myInstantServices);
          },
          onClose: () {
            Get.back();
            Get.until((r) => r.settings.name == AppRoutes.main);
            Get.toNamed(AppRoutes.myInstantServices);
          },
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        apiErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
