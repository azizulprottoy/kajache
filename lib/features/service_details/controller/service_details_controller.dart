import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/models/services_response_model.dart';
import '../../home/models/available_booking_response_model.dart';
import '../arguments/service_details_arguments.dart';
import '../repository/service_details_repository.dart';

class ServiceDetailsController extends GetxController {
  final ServiceDetailsRepository _repository =
  Get.find<ServiceDetailsRepository>();
  late final String serviceSlug;
  bool isBooking = false;
  bool isProviderBidFlow = false;
  int minLimit = 0;
  String bookingId = '';
  bool hasBid = false;
  String? myBidId;
  int? myBidPrice;
  String? myBidEstimatedArrival;
  String? myBidMessage;
  JobPosterModel? poster;
  bool _hasInvalidArgument = false;
  final RxBool isLoading = false.obs;
  final RxBool isBidLoading = false.obs;
  final Rxn<ServiceModel> service = Rxn<ServiceModel>();



  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ServiceDetailsArgument && args.serviceSlug.isNotEmpty) {
      serviceSlug = args.serviceSlug;
      isBooking = args.isbooking;
      isProviderBidFlow = args.isProviderBidFlow;
      minLimit = args.minLimit;
      bookingId = args.bookingId;
      hasBid = args.hasBid;
      myBidId = args.myBidId;
      myBidPrice = args.myBidPrice;
      myBidEstimatedArrival = args.myBidEstimatedArrival;
      myBidMessage = args.myBidMessage;
      poster = args.poster;
      debugPrint('[ServiceDetails] bookingId=$bookingId slug=$serviceSlug hasBid=$hasBid');
    } else {
      _hasInvalidArgument = true;
    }
  }

  @override
  void onReady() {
    super.onReady();

    if (_hasInvalidArgument) {
      Get.back();

      Get.snackbar(
        'Error',
        'Service ID not found',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    fetchServiceDetails();
  }

  Future<bool> submitBid({
    required double price,
    required String estimatedArrival,
    String message = '',
  }) async {
    debugPrint('[submitBid] bookingId=$bookingId price=$price eta=$estimatedArrival');
    if (bookingId.isEmpty) {
      Get.snackbar('Error', 'Booking ID missing — cannot place bid.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    isBidLoading.value = true;
    try {
      if (hasBid) {
        final bidId = myBidId;
        if (bidId == null || bidId.isEmpty) {
          throw Exception('Bid ID missing — cannot update bid.');
        }
        await _repository.updateBid(
          bookingId: bookingId,
          bidId: bidId,
          price: price,
          estimatedArrival: estimatedArrival,
          message: message,
        );
      } else {
        await _repository.placeBid(
          bookingId: bookingId,
          price: price,
          estimatedArrival: estimatedArrival,
          message: message,
        );
      }
      myBidPrice = price.round();
      myBidEstimatedArrival = estimatedArrival;
      myBidMessage = message;
      return true;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isClosed) {
          Get.snackbar(
            'Error',
            e.toString().replaceFirst('Exception: ', ''),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
      return false;
    } finally {
      if (!isClosed) isBidLoading.value = false;
    }
  }

  Future<void> fetchServiceDetails() {
    final slug = serviceSlug;

    if (slug.isEmpty) {
      return Future.value();
    }

    isLoading.value = true;

    return _repository
        .getServiceBySlug(slug)
        .then((data) {
      service.value = data;
    })
        .catchError((error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isClosed) {
          Get.snackbar(
            'Error',
            error.toString().replaceFirst('Exception: ', ''),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
    })
        .whenComplete(() {
      if (!isClosed) {
        isLoading.value = false;
      }
    });
  }
}
