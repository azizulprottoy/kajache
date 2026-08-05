import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../../payments/models/payment_method_model.dart';
import '../../payments/repository/payment_repository.dart';
import '../model/instant_service_model.dart';
import '../repository/instant_service_repository.dart';

/// Controller for the customer's single instant-service details page.
///
/// Mirrors `lib/features/my_bookings/controller/my_booking_details_controller.dart`
/// closely: fetch details, list bids, select a winning bid, then — once
/// `status == 'bid_selected' && paymentStatus != 'paid'` — pay the platform
/// fee via a bottom sheet (reusing `PaymentRepository`/`PaymentMethodModel`),
/// then mark the job completed once `in_progress`, or cancel.
class MyInstantServiceDetailsController extends GetxController {
  final InstantServiceRepository repository = InstantServiceRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();

  final isLoading = false.obs;
  final isSelectingBid = false.obs;
  final isSubmittingPayment = false.obs;
  final isCompletingTask = false.obs;
  final isCancelling = false.obs;

  final instantService = Rxn<InstantServiceDetailsModel>();
  final selectedBidder = Rxn<InstantServiceBidModel>();

  final selectedPaymentMethod = Rxn<PaymentMethodModel>();
  final paymentMethodsList = <PaymentMethodModel>[].obs;
  final isLoadingPaymentMethods = false.obs;

  String instantServiceId = '';

  bool get isPaymentDue =>
      instantService.value?.status.trim().toLowerCase() == 'bid_selected' &&
      instantService.value?.paymentStatus.trim().toLowerCase() != 'paid';

  int get platformFee => instantService.value?.platformFee ?? 0;

  InstantServiceBidModel? get selectedBid => instantService.value?.selectedBid;

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;

    if (arguments is String) {
      instantServiceId = arguments.trim();
    } else if (arguments is Map) {
      instantServiceId = arguments['id']?.toString().trim() ?? '';
    }

    if (instantServiceId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          TKeys.error.tr,
          'Instant service ID is missing',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return;
    }

    fetchInstantService();
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

  Future<void> fetchInstantService() async {
    if (instantServiceId.isEmpty) return;

    try {
      isLoading.value = true;
      final result = await repository.getInstantService(instantServiceId);
      instantService.value = result;
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

  void viewBidder(InstantServiceBidModel bid) {
    selectedBidder.value = bid;
  }

  void clearSelectedBidder() {
    selectedBidder.value = null;
  }

  Future<bool> selectBid(InstantServiceBidModel bid) async {
    if (instantServiceId.isEmpty || bid.id.isEmpty) {
      Get.snackbar(
        TKeys.error.tr,
        'Instant service or bid ID is missing',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (isSelectingBid.value) return false;

    try {
      isSelectingBid.value = true;
      await repository.selectBid(
        instantServiceId: instantServiceId,
        bidId: bid.id,
      );
      await fetchInstantService();
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

  Future<bool> confirmInstantServicePayment({
    required String transactionId,
  }) async {
    if (!isPaymentDue) {
      Get.snackbar(
        TKeys.error.tr,
        'Payment is not due for this instant service',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (transactionId.trim().isEmpty) {
      Get.snackbar(
        TKeys.error.tr,
        TKeys.transactionIdRequired.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (isSubmittingPayment.value) return false;

    try {
      isSubmittingPayment.value = true;
      await repository.confirmPayment(
        instantServiceId: instantServiceId,
        paymentMethod: selectedPaymentMethod.value?.name,
        transactionId: transactionId.trim(),
      );
      await fetchInstantService();
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

  Future<bool> completeInstantService() async {
    if (instantService.value?.status.trim().toLowerCase() != 'in_progress') {
      Get.snackbar(
        'Unable to complete',
        'Only an in-progress job can be marked as completed',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (isCompletingTask.value) return false;

    try {
      isCompletingTask.value = true;
      await repository.completeInstantService(instantServiceId);
      await fetchInstantService();
      return true;
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isCompletingTask.value = false;
    }
  }

  Future<bool> cancelInstantService({String reason = ''}) async {
    if (isCancelling.value) return false;

    try {
      isCancelling.value = true;
      await repository.cancelInstantService(instantServiceId, reason: reason);
      await fetchInstantService();
      Get.snackbar(
        TKeys.success.tr,
        'Instant service cancelled.',
        snackPosition: SnackPosition.BOTTOM,
      );
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
