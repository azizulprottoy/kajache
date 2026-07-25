import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/models/available_booking_response_model.dart';
import '../repository/my_booking_repository.dart';

class MyBookingDetailsController extends GetxController {
  final MyBookingRepository repository = MyBookingRepository();

  final isLoading = false.obs;
  final isBookingTechnician = false.obs;
  final isCompletingTask = false.obs;
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
          'Error',
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
        'Error',
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
        'Error',
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
        'Error',
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
        'Error',
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
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isCompletingTask.value = false;
    }
  }
}
