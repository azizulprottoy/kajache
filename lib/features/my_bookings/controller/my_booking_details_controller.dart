import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/models/available_booking_response_model.dart';
import '../../../core/utils/translation_keys.dart';
import '../repository/my_booking_repository.dart';

class MyBookingDetailsController extends GetxController {
  final MyBookingRepository repository = MyBookingRepository();

  final isLoading = false.obs;
  final isBookingTechnician = false.obs;
  final isCompletingTask = false.obs;
  final isSubmittingServiceReview = false.obs;
  final isSubmittingProviderRating = false.obs;
  final booking = Rxn<AvailableBookingModel>();
  final selectedBidder = Rxn<BookingBidModel>();

  String bookingId = '';

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
}
