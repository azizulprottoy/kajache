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
  final RxBool isMarkingCash = false.obs;
  final RxBool isCancellingBid = false.obs;
  final RxBool isRespondingReassignment = false.obs;
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
      return;
    }
    fetchBooking();
  }

  Future<void> fetchBooking() async {
    isLoading.value = true;
    try {
      booking.value = await _repository.getBooking(bookingId);
    } catch (error) {
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
      return false;
    } finally {
      if (!isClosed) isBidLoading.value = false;
    }
  }

  Future<bool> cancelBid({String reason = ''}) async {
    if (isCancellingBid.value) return false;
    isCancellingBid.value = true;
    try {
      await _repository.cancelBid(bookingId, reason: reason);
      await fetchBooking();
      Get.snackbar(TKeys.success.tr, 'Bid cancelled.',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      return false;
    } finally {
      if (!isClosed) isCancellingBid.value = false;
    }
  }

  Future<bool> respondReassignment({required bool accept}) async {
    if (isRespondingReassignment.value) return false;
    isRespondingReassignment.value = true;
    try {
      await _repository.respondReassignment(bookingId, accept: accept);
      await fetchBooking();
      return true;
    } catch (e) {
      return false;
    } finally {
      if (!isClosed) isRespondingReassignment.value = false;
    }
  }

  Future<bool> markCashReceived() async {
    isMarkingCash.value = true;
    try {
      await _repository.markCashReceived(bookingId);
      await fetchBooking();
      Get.snackbar(TKeys.success.tr, TKeys.cashReceivedConfirmed.tr,
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      return false;
    } finally {
      if (!isClosed) isMarkingCash.value = false;
    }
  }
}
