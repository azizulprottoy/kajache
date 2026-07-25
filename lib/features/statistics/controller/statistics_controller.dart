import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/models/available_booking_response_model.dart';
import '../repository/statistics_repository.dart';

class StatisticsController extends GetxController {
  final StatisticsRepository _repository = Get.find<StatisticsRepository>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ProviderBidModel> acceptedBookings =
      <ProviderBidModel>[].obs;
  final RxSet<String> processingBookingIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAcceptedBookings();
  }

  Future<void> fetchAcceptedBookings() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      acceptedBookings.assignAll(
        await _repository.getAcceptedBookings(),
      );
    } catch (error) {
      errorMessage.value =
          error.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  bool isProcessing(String bookingId) =>
      processingBookingIds.contains(bookingId);

  bool canMakeInProgress(ProviderBidModel booking) =>
      booking.bookingStatus.trim().toLowerCase() == 'bid_selected';

  bool isInProgress(ProviderBidModel booking) =>
      booking.bookingStatus.trim().toLowerCase() == 'in_progress';

  Future<void> confirmMakeInProgress(
    ProviderBidModel booking,
  ) async {
    if (!canMakeInProgress(booking) ||
        isProcessing(booking.bookingId)) {
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Start this booking?'),
        content: const Text(
          'The booking status will be changed to in progress.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Make In Progress'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await makeInProgress(booking);
    }
  }

  Future<void> makeInProgress(ProviderBidModel booking) async {
    final bookingId = booking.bookingId.trim();
    if (bookingId.isEmpty ||
        !canMakeInProgress(booking) ||
        isProcessing(bookingId)) {
      return;
    }

    processingBookingIds.add(bookingId);
    try {
      await _repository.makeBookingInProgress(bookingId);
      await fetchAcceptedBookings();

      Get.snackbar(
        'Success',
        'Booking is now in progress.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      processingBookingIds.remove(bookingId);
    }
  }
}
