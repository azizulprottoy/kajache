import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/models/available_booking_response_model.dart';
import '../../../core/utils/translation_keys.dart';
import '../../payments/models/coupon_model.dart';
import '../../payments/models/payment_method_model.dart';
import '../../payments/repository/payment_repository.dart';
import '../repository/my_booking_repository.dart';

class MyBookingDetailsController extends GetxController {
  final MyBookingRepository repository = MyBookingRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();

  final isLoading = false.obs;
  final isBookingTechnician = false.obs;
  final isCompletingTask = false.obs;
  final isSubmittingServiceReview = false.obs;
  final isSubmittingProviderRating = false.obs;
  final isSubmittingComplaint = false.obs;
  final isSubmittingPayment = false.obs;
  final booking = Rxn<AvailableBookingModel>();
  final selectedBidder = Rxn<BookingBidModel>();

  final selectedPaymentMethod = Rxn<PaymentMethodModel>();
  final paymentMethodsList = <PaymentMethodModel>[].obs;
  final isLoadingPaymentMethods = false.obs;

  // ── Coupon ──────────────────────────────────────────────────────────────────
  final coupons = <CouponModel>[].obs;
  final appliedCoupon = Rxn<CouponModel>();
  final couponError = ''.obs;
  final isLoadingCoupons = false.obs;

  int get discountAmount {
    final coupon = appliedCoupon.value;
    if (coupon == null) return 0;
    final base = basePaymentAmount;
    return coupon.discountFor(base).clamp(0, base);
  }

  int get basePaymentAmount {
    final b = booking.value;
    if (b == null) return 0;
    final selectedBid = b.bids.cast<BookingBidModel?>()
        .firstWhere((bid) => bid?.status.toLowerCase() == 'selected', orElse: () => null);
    return b.bookingFee + (selectedBid?.price ?? 0);
  }

  int get finalPaymentAmount => basePaymentAmount - discountAmount;

  void applyCoupon(String code) {
    final trimmed = code.trim().toUpperCase();
    final match = coupons.cast<CouponModel?>().firstWhere(
      (c) => c?.code.toUpperCase() == trimmed,
      orElse: () => null,
    );
    if (match == null || !match.isValid) {
      couponError.value = TKeys.invalidCoupon.tr;
      appliedCoupon.value = null;
    } else {
      appliedCoupon.value = match;
      couponError.value = '';
    }
  }

  void removeCoupon() {
    appliedCoupon.value = null;
    couponError.value = '';
  }

  String bookingId = '';

  bool get isPaymentDue =>
      booking.value?.status.trim().toLowerCase() == 'bid_selected' &&
      booking.value?.paymentStatus.trim().toLowerCase() != 'paid';

  String? get assignedTechnicianId {
    final bids = booking.value?.bids ?? [];
    for (final bid in bids) {
      if (bid.status.trim().toLowerCase() == 'selected') {
        return bid.providerId;
      }
    }
    return null;
  }

  String? get selectedBidId {
    final bids = booking.value?.bids ?? [];
    for (final bid in bids) {
      if (bid.status.trim().toLowerCase() == 'selected') {
        return bid.id;
      }
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;

    if (arguments is String) {
      bookingId = arguments.trim();
    } else if (arguments is Map) {
      bookingId = arguments['bookingId']?.toString().trim() ?? '';
    }

    if (bookingId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          TKeys.error.tr,
          'Booking ID is missing',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return;
    }

    fetchBooking();
    _fetchPaymentMethods();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    isLoadingCoupons.value = true;
    try {
      final list = await _paymentRepository.getCoupons();
      coupons.assignAll(list);
    } catch (_) {
    } finally {
      if (!isClosed) isLoadingCoupons.value = false;
    }
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

  Future<void> fetchBooking() async {
    if (bookingId.isEmpty) return;

    try {
      isLoading.value = true;

      final result = await repository.getBooking(bookingId);
      booking.value = result;
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

  void viewBidder(BookingBidModel bid) {
    selectedBidder.value = bid;
  }

  void clearSelectedBidder() {
    selectedBidder.value = null;
  }

  Future<bool> bookTechnician(BookingBidModel bid) async {
    if (bookingId.isEmpty || bid.id.isEmpty) {
      Get.snackbar(
        TKeys.error.tr,
        'Booking or bid ID is missing',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (isBookingTechnician.value) return false;

    try {
      isBookingTechnician.value = true;

      await repository.selectBid(
        bookingId: bookingId,
        bidId: bid.id,
      );
      await fetchBooking();

      return true;
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isBookingTechnician.value = false;
    }
  }

  Future<bool> confirmBookingPayment({required String transactionId, bool isCash = false}) async {
    if (!isPaymentDue) {
      Get.snackbar(
        TKeys.error.tr,
        'Payment is not due for this booking',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (isSubmittingPayment.value) return false;

    try {
      isSubmittingPayment.value = true;
      await repository.confirmPayment(
        bookingId,
        paymentMethod: isCash ? 'cash' : (selectedPaymentMethod.value?.name ?? ''),
        transactionId: transactionId.trim(),
      );
      await fetchBooking();
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

  Future<bool> completeTask() async {
    if (bookingId.isEmpty) {
      Get.snackbar(
        TKeys.error.tr,
        'Booking ID is missing',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (booking.value?.status.trim().toLowerCase() != 'in_progress') {
      Get.snackbar(
        'Unable to complete',
        'Only an in-progress booking can be marked as completed',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (isCompletingTask.value) return false;

    try {
      isCompletingTask.value = true;

      await repository.completeBooking(bookingId);
      await fetchBooking();

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

  Future<bool> submitServiceReview({
    required int rating,
    required String review,
  }) async {
    final currentBooking = booking.value;
    if (currentBooking == null ||
        currentBooking.status.trim().toLowerCase() != 'completed' ||
        currentBooking.serviceRated ||
        isSubmittingServiceReview.value) {
      return false;
    }

    try {
      isSubmittingServiceReview.value = true;
      await repository.submitServiceReview(
        bookingId: bookingId,
        rating: rating,
        review: review.trim(),
      );
      await fetchBooking();
      return true;
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmittingServiceReview.value = false;
    }
  }

  Future<bool> submitProviderRating({
    required int rating,
    String? comment,
  }) async {
    final currentBooking = booking.value;
    if (currentBooking == null ||
        currentBooking.status.trim().toLowerCase() != 'completed' ||
        currentBooking.providerRated ||
        isSubmittingProviderRating.value) {
      return false;
    }

    try {
      isSubmittingProviderRating.value = true;
      await repository.submitProviderRating(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
      await fetchBooking();
      return true;
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmittingProviderRating.value = false;
    }
  }

  Future<bool> submitComplaint({
    required String title,
    required String reason,
  }) async {
    final technicianId = assignedTechnicianId;

    if (technicianId == null || technicianId.isEmpty) {
      Get.snackbar(
        TKeys.error.tr,
        'No technician found for this booking',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (isSubmittingComplaint.value) return false;

    try {
      isSubmittingComplaint.value = true;
      await repository.submitComplaint(
        complainAgainst: technicianId,
        title: title.trim(),
        reason: reason.trim(),
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
      isSubmittingComplaint.value = false;
    }
  }
}
