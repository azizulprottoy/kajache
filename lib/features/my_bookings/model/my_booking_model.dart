class MyBookingModel {
  final String id;
  final String serviceName;
  final String serviceSlug;
  final String details;
  final String status;

  final int minLimit;
  final int bookingFee;

  final String paymentStatus;

  final String address;
  final String city;
  final String date;
  final String time;

  MyBookingModel({
    required this.id,
    required this.serviceName,
    required this.serviceSlug,
    required this.details,
    required this.status,
    required this.minLimit,
    required this.bookingFee,
    required this.paymentStatus,
    required this.address,
    required this.city,
    required this.date,
    required this.time,
  });

  factory MyBookingModel.fromJson(Map<String, dynamic> json) {
    return MyBookingModel(
      id: json['_id']?.toString() ?? '',

      serviceName: json['service']?['title']?.toString() ?? 'Unknown Service',
      serviceSlug: json['service']?['slug']?.toString() ?? '',

      details: json['details']?.toString() ?? '',
      status: json['status']?.toString() ?? '',

      minLimit: (json['minLimit'] ?? 0) is int
          ? json['minLimit']
          : int.tryParse(json['minLimit']?.toString() ?? '0') ?? 0,

      bookingFee: (json['bookingFee'] ?? 0) is int
          ? json['bookingFee']
          : int.tryParse(json['bookingFee']?.toString() ?? '0') ?? 0,

      paymentStatus: json['paymentStatus']?.toString() ?? '',

      address: json['location']?['address']?.toString() ?? '',
      city: json['location']?['city']?.toString() ?? '',

      date: json['schedule']?['date']?.toString() ?? '',
      time: json['schedule']?['time']?.toString() ?? '',
    );
  }
}