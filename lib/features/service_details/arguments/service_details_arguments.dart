import '../../home/models/available_booking_response_model.dart';

class ServiceDetailsArgument {
  final String serviceSlug;
  final bool isbooking;
  final bool isProviderBidFlow;
  final int minLimit;
  final String bookingId;
  final bool hasBid;
  final String? myBidId;
  final int? myBidPrice;
  final String? myBidEstimatedArrival;
  final String? myBidMessage;
  final JobPosterModel? poster;

  ServiceDetailsArgument({
    required this.serviceSlug,
    this.isbooking = false,
    this.isProviderBidFlow = false,
    this.minLimit = 0,
    this.bookingId = '',
    this.hasBid = false,
    this.myBidId,
    this.myBidPrice,
    this.myBidEstimatedArrival,
    this.myBidMessage,
    this.poster,
  });
}

