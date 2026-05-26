class ServiceDetailsArgument {
  final String serviceSlug;
  final bool isbooking;
  final bool isProviderBidFlow;

  ServiceDetailsArgument({
    required this.serviceSlug,
    this.isbooking = false,
    this.isProviderBidFlow = false,
  });
}

