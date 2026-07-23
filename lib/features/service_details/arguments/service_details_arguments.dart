class ServiceDetailsArgument {
  final String serviceSlug;
  final bool isbooking;
  final bool isProviderBidFlow;
  final int minLimit;
  final String bookingId;
  final bool hasBid;
  final int? myBidPrice;

  ServiceDetailsArgument({
    required this.serviceSlug,
    this.isbooking = false,
    this.isProviderBidFlow = false,
    this.minLimit = 0,
    this.bookingId = '',
    this.hasBid = false,
    this.myBidPrice,
  });
}

