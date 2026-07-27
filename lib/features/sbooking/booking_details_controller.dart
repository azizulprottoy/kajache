import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home/models/available_booking_response_model.dart';
import 'booking_details_arguments.dart';
import '../../core/utils/translation_keys.dart';
import 'booking_details_repository.dart';


class BookingDetailsController extends GetxController {
  final BookingDetailsRepository _repository =
      Get.find<BookingDetailsRepository>();

  final RxBool isLoading = true.obs;
  final RxBool isBidLoading = false.obs;
  final Rxn<AvailableBookingModel> booking =
      Rxn<AvailableBookingModel>();

  late final String bookingId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    bookingId =
        args is BookingDetailsArgument ? args.bookingId.trim() : '';
  }

  @override
  void onReady() {
    super.onReady();
    if (bookingId.isEmpty) {
      Get.back();
      Get.snackbar(TKeys.error.tr, TKeys.bookingIdMissing.tr);
      return;
    }
    fetchBooking();
  }

  Future<void> fetchBooking() async {
    isLoading.value = true;
    try {
      booking.value = await _repository.getBooking(bookingId);
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isClosed) {
          Get.snackbar(
            TKeys.error.tr,
            error.toString().replaceFirst('Exception: ', ''),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<bool> submitBid({
    required double price,
    required String estimatedArrival,
    required String message,
  }) async {
    final current = booking.value;
    if (current == null) return false;

    isBidLoading.value = true;
    try {
      final ProviderBidModel savedBid;
      if (current.hasBid) {
        final bidId = current.myBidId;
        if (bidId == null || bidId.isEmpty) {
          throw Exception('Bid ID is missing.');
        }
        savedBid = await _repository.updateBid(
          bookingId: bookingId,
          bidId: bidId,
          price: price,
          estimatedArrival: estimatedArrival,
          message: message,
        );
      } else {
        savedBid = await _repository.placeBid(
          bookingId: bookingId,
          price: price,
          estimatedArrival: estimatedArrival,
          message: message,
        );
      }
      booking.value = current.withMyBid(savedBid);
      await fetchBooking();
      return true;
    } catch (error) {
      Get.snackbar(
        TKeys.error.tr,
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      if (!isClosed) isBidLoading.value = false;
    }
  }
}
