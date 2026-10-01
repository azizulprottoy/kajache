import 'dart:io';

class BookingRequestModel {
  final String service;
  final String title;
  final bool isDraft;
  /// Up to 8 job photos; sent as multipart `photos` files
  final List<File> photos;
  final String details;
  final List<String> subServices;
  final LocationModel location;
  final ScheduleModel schedule;
  final String? paymentMethod;
  final String? transactionId;

  BookingRequestModel({
    required this.service,
    required this.title,
    this.isDraft = false,
    this.photos = const [],
    required this.details,
    required this.subServices,
    required this.location,
    required this.schedule,
    this.paymentMethod,
    this.transactionId,
  });

  Map<String, dynamic> toJson() {
    return {
      "service": service,
      "title": title,
      "isDraft": isDraft,
      "details": details,
      "subServices": subServices,
      "location": location.toJson(),
      "schedule": schedule.toJson(),
      if (paymentMethod != null) "paymentMethod": paymentMethod,
      if (transactionId != null && transactionId!.isNotEmpty)
        "transactionId": transactionId,
    };
  }
}

class LocationModel {
  final String address;
  /// Optional; the backend defaults it to Dhaka
  final String? city;
  final double? lat;
  final double? lng;
  final String? district;

  LocationModel({
    required this.address,
    this.city,
    this.lat,
    this.lng,
    this.district,
  });

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      if (city != null) "city": city,
      if (district != null) "district": district,
      if (lat != null && lng != null) "coordinates": {"lat": lat, "lng": lng},
    };
  }
}

class ScheduleModel {
  final String date;
  final String time;

  ScheduleModel({
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "time": time,
    };
  }
}