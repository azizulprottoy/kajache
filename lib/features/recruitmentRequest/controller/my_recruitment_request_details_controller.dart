import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../../payments/models/payment_method_model.dart';
import '../../payments/repository/payment_repository.dart';
import '../model/recruitment_request_model.dart';
import '../repository/recruitment_request_repository.dart';

/// Controller for the customer-facing "My Job Post" details screen.
///
/// Differences from Booking/Instant Service's details controller:
/// - There is no post-selection payment step — the posting fee was already
///   paid before bidding opened. `isPaymentDue` here only exists as a
///   FALLBACK, covering the case where the create-flow's inline payment
///   step failed or was dismissed and the request is stuck in
///   `pending_payment`.
/// - Picking an applicant ("select-bid") immediately "hires" them — there
///   is no separate technician-acceptance step.
/// - Once hired, the customer ends the engagement directly (no
///   "mark completed" + rating flow).
class MyRecruitmentRequestDetailsController extends GetxController {
  final RecruitmentRequestRepository repository = RecruitmentRequestRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();

  final isLoading = false.obs;
  final isSelectingBid = false.obs;
  final isEnding = false.obs;
  final isCancelling = false.obs;
  final isSubmittingPayment = false.obs;

  final request = Rxn<RecruitmentRequestDetailsModel>();
  final selectedApplicant = Rxn<RecruitmentBidModel>();

  final selectedPaymentMethod = Rxn<PaymentMethodModel>();
  final paymentMethodsList = <PaymentMethodModel>[].obs;
  final isLoadingPaymentMethods = false.obs;

  String requestId = '';

  bool get isPaymentDue => request.value?.isPaymentDue ?? false;

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;

    if (arguments is String) {
      requestId = arguments.trim();
    } else if (arguments is Map) {
      requestId = arguments['id']?.toString().trim() ?? '';
    }

    if (requestId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          TKeys.error.tr,
          'Recruitment request ID is missing',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return;
    }

    fetchRequest();
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    isLoadingPaymentMethods.value = true;
    try {
      final methods = await _paymentRepository.getPaymentMethods();
      paymentMethodsList.assignAll(methods);
      if (methods.isNotEmpty) selectedPaymentMethod.value = methods.first;
    } catch (_) {
    } finally {
      if (!isClosed) isLoadingPaymentMethods.value = false;
    }
  }

  Future<void> fetchRequest() async {
    if (requestId.isEmpty) return;

    try {
      isLoading.value = true;
      final result = await repository.getRecruitmentRequest(requestId);
      request.value = result;
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

  void viewApplicant(RecruitmentBidModel bid) {
    selectedApplicant.value = bid;
  }

  /// Fallback pay-to-post — used if the inline payment step during
  /// creation failed/was dismissed and the request is stuck in
  /// `pending_payment`.
  Future<bool> payToPost({required String transactionId}) async {
    if (!isPaymentDue) {
      Get.snackbar(
        TKeys.error.tr,
        'Payment is not due for this job post',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (isSubmittingPayment.value) return false;

    try {
      isSubmittingPayment.value = true;
      await repository.confirmPayment(
        requestId,
        paymentMethod: selectedPaymentMethod.value?.name,
        transactionId: transactionId.trim(),
      );
      await fetchRequest();
      return true;
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmittingPayment.value = false;
    }
  }

  /// Hires an applicant — transitions the posting to `hired`. There is no
  /// separate technician-acceptance step for this feature.
  Future<bool> hireApplicant(RecruitmentBidModel bid) async {
    if (requestId.isEmpty || bid.id.isEmpty) return false;
    if (isSelectingBid.value) return false;

    try {
      isSelectingBid.value = true;
      await repository.selectBid(requestId, bid.id);
      await fetchRequest();
      return true;
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSelectingBid.value = false;
    }
  }

  Future<bool> endEngagement() async {
    if (requestId.isEmpty) return false;
    if (isEnding.value) return false;

    try {
      isEnding.value = true;
      await repository.endRecruitmentRequest(requestId);
      await fetchRequest();
      return true;
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isEnding.value = false;
    }
  }

  Future<bool> cancelRequest({String? reason}) async {
    if (requestId.isEmpty) return false;
    if (isCancelling.value) return false;

    try {
      isCancelling.value = true;
      await repository.cancelRecruitmentRequest(requestId, reason: reason);
      await fetchRequest();
      return true;
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isCancelling.value = false;
    }
  }
}
