import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/success_model.dart';
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

  RxnString selectedCity = RxnString();
  RxnString selectedTime = RxnString();

  final cities = const [
    'Dhaka',
    'Chittagong',
    'Sylhet',
    'Rajshahi',
    'Khulna',
    'Barisal',
  ];

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
          'Technicians cannot post instant services.',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return;
    }

    selectedCity.value = 'Dhaka';
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
    if (!(formKey.currentState?.validate() ?? false)) return;

    final priceMin = int.tryParse(priceMinController.text.trim()) ?? 0;
    final priceMax = int.tryParse(priceMaxController.text.trim()) ?? 0;

    if (priceMax <= priceMin) {
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

    final detailsHtml = (await detailsEditorController.getText()).trim();
    if (_isDetailsHtmlEmpty(detailsHtml)) {
      Get.snackbar(
        TKeys.validation.tr,
        TKeys.describeProblemError.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade700,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
      return;
    }

    try {
      isLoading.value = true;

      /// CREATE INSTANT SERVICE (no payment yet — bidding opens right away;
      /// payment happens after the client selects a winning bid).
      await repository.createInstantService(
        title: titleController.text.trim(),
        details: detailsHtml,
        priceMin: priceMin,
        priceMax: priceMax,
        location: InstantServiceLocationModel(
          address: addressController.text.trim(),
          city: selectedCity.value ?? 'Dhaka',
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
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
