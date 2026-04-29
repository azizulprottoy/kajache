class ServiceArgument {
  final String ServiceID;
  final bool isbooking;
  final bool isProviderBidFlow;

  ServiceArgument({
    required this.ServiceID,
    this.isbooking = false,
    this.isProviderBidFlow = false,
  });
}