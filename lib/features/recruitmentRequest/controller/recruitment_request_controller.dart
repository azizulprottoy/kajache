import 'package:kaj_ache/core/error/api_error.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/success_model.dart';
import '../../payments/models/payment_method_model.dart';
import '../../payments/repository/payment_repository.dart';
import '../repository/recruitment_request_repository.dart';

/// Controller for the "Post a Job" (Recruitment Request) creation flow.
///
/// Unlike Booking, this is a 2-step wizard where step 2 is PAYMENT — the
/// posting fee must be paid before bidding opens, so `submitRequest()`
/// creates the request and then immediately confirms payment, instead of
/// deferring payment to a later "select bid" step.
class RecruitmentRequestController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final RecruitmentRequestRepository repository = RecruitmentRequestRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();
  final ImagePicker _imagePicker = ImagePicker();

  static const int lastStep = 2;
  final currentStep = 1.obs;
  final isLoading = false.obs;

  /// Step 1 — job details
  final titleController = TextEditingController();
  final detailsEditorController = HtmlEditorController();
  final durationController = TextEditingController();
  final salaryController = TextEditingController();
  final salaryValue = 0.0.obs;
  final durationValue = ''.obs;

  /// API limits (see API_Server src/utils/jobRequest.js TEXT_LIMITS).
  static const int titleMaxLength = 150;
  static const int durationMaxLength = 100;
  static const int detailsMaxLength = 5000;
  static const int maxSalary = 10000000;

  /// Optional cover photo submitted alongside the post.
  final pickedImage = Rxn<File>();

  /// Step 2 — pay to post
  final transactionIdController = TextEditingController();
  final selectedPaymentMethod = Rxn<PaymentMethodModel>();
  final paymentMethodsList = <PaymentMethodModel>[].obs;
  final isLoadingPaymentMethods = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchPaymentMethods();
  }

  @override
  void onClose() {
    titleController.dispose();
    durationController.dispose();
    salaryController.dispose();
    transactionIdController.dispose();
    super.onClose();
  }

  Future<void> _fetchPaymentMethods() async {
    isLoadingPaymentMethods.value = true;
    try {
      final methods = await _paymentRepository.getPaymentMethods();
      paymentMethodsList.assignAll(methods);
      if (methods.isNotEmpty) selectedPaymentMethod.value = methods.first;
    } catch (_) {
      // Non-fatal — the payment step still allows entering a transaction id.
    } finally {
      if (!isClosed) isLoadingPaymentMethods.value = false;
    }
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

  /// First problem with the job details, or null when they're valid.
  String? _detailsError() {
    if (titleController.text.trim().isEmpty) return TKeys.jobTitleRequired.tr;
    if (durationController.text.trim().isEmpty) return TKeys.durationRequired.tr;
    final salary = num.tryParse(salaryController.text.trim());
    if (salary == null || salary <= 0) return TKeys.salaryInvalid.tr;
    if (salary > maxSalary) return TKeys.amountTooLarge.tr;
    return null;
  }

  String? validateStep() {
    if (currentStep.value == 1) {
      final error = _detailsError();
      if (error != null) return error;
    }

    if (currentStep.value == 2) {
      if (transactionIdController.text.trim().isEmpty) {
        return TKeys.transactionIdRequired.tr;
      }
    }

    return null;
  }

  void nextStep(BuildContext context) {
    final error = validateStep();

    if (error != null) {
      Get.snackbar(
        TKeys.validation.tr,
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade700,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
      return;
    }

    if (currentStep.value < lastStep) {
      currentStep.value++;
    }
  }

  void prevStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  Future<void> submitRequest() async {
    // A second tap while creating/paying would post the job twice
    if (isLoading.value) return;

    // Validate all fields regardless of step
    final detailsError = _detailsError();
    if (detailsError != null) {
      Get.snackbar(TKeys.validation.tr, detailsError, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (transactionIdController.text.trim().isEmpty) {
      Get.snackbar(TKeys.validation.tr, TKeys.transactionIdRequired.tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      final detailsHtml = (await detailsEditorController.getText()).trim();
      if (detailsHtml.length > detailsMaxLength) {
        Get.snackbar(
          TKeys.validation.tr,
          TKeys.detailsTooLong.trParams({'max': '$detailsMaxLength'}),
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      /// 1. CREATE the job posting — starts as `pending_payment`, bidding
      /// is not open yet.
      final created = await repository.createRecruitmentRequest(
        title: titleController.text,
        details: _isDetailsHtmlEmpty(detailsHtml) ? null : detailsHtml,
        duration: durationController.text,
        salary: num.tryParse(salaryController.text.trim()) ?? 0,
        imageFile: pickedImage.value,
      );

      /// 2. PAY THE POSTING FEE — THIS is what opens bidding. This is the
      /// key difference from Booking/Instant Service, where payment happens
      /// only after a bid is selected.
      try {
        await repository.confirmPayment(
          created.id,
          paymentMethod: selectedPaymentMethod.value?.name,
          transactionId: transactionIdController.text,
        );

        await Get.dialog(
          SuccessModal(
            title: TKeys.recruitmentPosted.tr,
            message: TKeys.recruitmentPostedMsg.tr,
            yesText: TKeys.viewMyJobPosts.tr,
            onYes: () {
              Get.back();
              Get.until((r) => r.settings.name == AppRoutes.main);
              Get.toNamed(AppRoutes.myRecruitmentRequests);
            },
            onClose: () {
              Get.back();
              Get.until((r) => r.settings.name == AppRoutes.main);
              Get.toNamed(AppRoutes.myRecruitmentRequests);
            },
          ),
          barrierDismissible: false,
        );
      } catch (paymentError) {
        // Job was created, but payment failed/was rejected. Don't strand
        // the user on this form — send them to My Job Posts where a
        // "Pay to Post" banner lets them retry (see
        // MyRecruitmentRequestDetailsController).
        Get.snackbar(
          TKeys.error.tr,
          TKeys.recruitmentPaymentFailedMsg.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        Get.until((r) => r.settings.name == AppRoutes.main);
        Get.toNamed(AppRoutes.myRecruitmentRequests);
      }
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

  void cancel() => Get.back();
}
