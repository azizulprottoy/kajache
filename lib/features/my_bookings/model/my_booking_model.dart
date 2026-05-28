class MyBookingModel {
  final String id;
  final String serviceName;
  final String details;
  final String status;
  final int maxLimit;
  final String address;
  final String city;
  final String date;
  final String time;

  MyBookingModel({
    required this.id,
    required this.serviceName,
    required this.details,
    required this.status,
    required this.maxLimit,
    required this.address,
    required this.city,
    required this.date,
    required this.time,
  });

  factory MyBookingModel.fromJson(Map<String, dynamic> json) {
    return MyBookingModel(
      id: json['_id']?.toString() ?? '',

      serviceName: json['service']?['title']?.toString() ?? 'Unknown Service',

      details: json['details']?.toString() ?? '',

      status: json['status']?.toString() ?? '',

      maxLimit: json['maxLimit'] ?? 0,

      address: json['location']?['address']?.toString() ?? '',

      city: json['location']?['city']?.toString() ?? '',

      date: json['schedule']?['date']?.toString() ?? '',

      time: json['schedule']?['time']?.toString() ?? '',
    );
  }
}
