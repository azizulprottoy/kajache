import 'package:dio/dio.dart';
import 'package:kaj_ache/core/error/api_error.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/storage/local_storage_service.dart';
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
/// - Once hired, the customer ends the engagement directly, then can rate
///   the technician once.
class MyRecruitmentRequestDetailsController extends GetxController {
  final RecruitmentRequestRepository repository = RecruitmentRequestRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();

  final isLoading = false.obs;
  final isSelectingBid = false.obs;
  final isEnding = false.obs;
  final isCancelling = false.obs;
  final isSubmittingPayment = false.obs;
  final isSubmittingReview = false.obs;
  final isSubmittingComplaint = false.obs;

  /// Starts true so "Rate technician" stays hidden until the check returns.
  final hasReviewed = true.obs;

  final request = Rxn<RecruitmentRequestDetailsModel>();
  final selectedApplicant = Rxn<RecruitmentBidModel>();

  final selectedPaymentMethod = Rxn<PaymentMethodModel>();
  final paymentMethodsList = <PaymentMethodModel>[].obs;
  final isLoadingPaymentMethods = false.obs;

  String requestId = '';

  bool get isPaymentDue => request.value?.isPaymentDue ?? false;

  String get _currentUserId => Get.find<LocalStorageService>().read<String>('user_id') ?? '';

  bool get isOwner {
    final currentUserId = _currentUserId;
    return currentUserId.isNotEmpty && currentUserId == request.value?.clientId;
  }

  String get status => request.value?.status.trim().toLowerCase() ?? '';

  /// pending_payment (nothing paid), hiring_open (refund requested) and
  /// hired (fee forfeited) can all be cancelled.
  bool get canCancel =>
      isOwner && (status == 'pending_payment' || status == 'hiring_open' || status == 'hired');

  bool get canReview => isOwner && status == 'ended' && !hasReviewed.value;

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
          TKeys.jobIdMissing.tr,
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
      _checkReviewed();
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

  Future<void> _checkReviewed() async {
    if (!isOwner || status != 'ended') return;
    try {
      hasReviewed.value = await repository.hasReviewed(requestId, _currentUserId);
    } catch (_) {
      // Unknown: offer the button; a repeat review gets a 409 anyway
      hasReviewed.value = false;
    }
  }

  Future<bool> submitReview({required int rating, required String review}) async {
    if (isSubmittingReview.value) return false;

    try {
      isSubmittingReview.value = true;
      await repository.submitReview(requestId, rating: rating, review: review);
      hasReviewed.value = true;
      return true;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 409) hasReviewed.value = true;
      Get.snackbar(
        TKeys.error.tr,
        apiErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmittingReview.value = false;
    }
  }

  Future<bool> submitComplaint({required String title, required String reason}) async {
    if (isSubmittingComplaint.value) return false;

    try {
      isSubmittingComplaint.value = true;
      await repository.submitComplaint(requestId, title: title, reason: reason);
      return true;
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        apiErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmittingComplaint.value = false;
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
        TKeys.paymentNotDue.tr,
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
      // Someone else changed the job first (409): show its current state
      if (e is DioException && e.response?.statusCode == 409) fetchRequest();
      Get.snackbar(
        TKeys.error.tr,
        apiErrorMessage(e),
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
      // Someone else changed the job first (409): show its current state
      if (e is DioException && e.response?.statusCode == 409) fetchRequest();
      Get.snackbar(
        TKeys.error.tr,
        apiErrorMessage(e),
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
      // Someone else changed the job first (409): show its current state
      if (e is DioException && e.response?.statusCode == 409) fetchRequest();
      Get.snackbar(
        TKeys.error.tr,
        apiErrorMessage(e),
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
      // Someone else changed the job first (409): show its current state
      if (e is DioException && e.response?.statusCode == 409) fetchRequest();
      Get.snackbar(
        TKeys.error.tr,
        apiErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isCancelling.value = false;
    }
  }
}
