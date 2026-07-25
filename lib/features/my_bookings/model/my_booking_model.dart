class MyBookingModel {
  final String id;
  final String clientId;

  final String serviceId;
  final String serviceName;
  final String serviceSlug;
  final String categoryId;

  final String details;
  final List<dynamic> subServices;

  final int bidsCount;
  final int minLimit;
  final int bookingFee;

  final String paymentStatus;
  final String status;
  final bool providerRated;
  final bool serviceRated;

  final String address;
  final String city;
  final String date;
  final String time;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MyBookingModel({
    required this.id,
    required this.clientId,
    required this.serviceId,
    required this.serviceName,
    required this.serviceSlug,
    required this.categoryId,
    required this.details,
    required this.subServices,
    required this.bidsCount,
    required this.minLimit,
    required this.bookingFee,
    required this.paymentStatus,
    required this.status,
    required this.providerRated,
    required this.serviceRated,
    required this.address,
    required this.city,
    required this.date,
    required this.time,
    this.createdAt,
    this.updatedAt,
  });

  factory MyBookingModel.fromJson(Map<String, dynamic> json) {
    final service = json['service'] is Map
        ? Map<String, dynamic>.from(json['service'] as Map)
        : <String, dynamic>{};

    final location = json['location'] is Map
        ? Map<String, dynamic>.from(json['location'] as Map)
        : <String, dynamic>{};

    final schedule = json['schedule'] is Map
        ? Map<String, dynamic>.from(json['schedule'] as Map)
        : <String, dynamic>{};

    return MyBookingModel(
      id: json['_id']?.toString() ?? '',
      clientId: json['client']?.toString() ?? '',

      serviceId: service['_id']?.toString() ?? '',
      serviceName: service['title']?.toString() ?? 'Unknown Service',
      serviceSlug: service['slug']?.toString() ?? '',
      categoryId: service['category']?.toString() ?? '',

      details: json['details']?.toString() ?? '',

      subServices: json['subServices'] is List
          ? List<dynamic>.from(json['subServices'] as List)
          : <dynamic>[],

      bidsCount: _toInt(json['bidsCount']),
      minLimit: _toInt(json['minLimit']),
      bookingFee: _toInt(json['bookingFee']),

      paymentStatus: json['paymentStatus']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      providerRated: json['providerRated'] == true,
      serviceRated: json['serviceRated'] == true,

      address: location['address']?.toString() ?? '',
      city: location['city']?.toString() ?? '',

      date: schedule['date']?.toString() ?? '',
      time: schedule['time']?.toString() ?? '',

      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
