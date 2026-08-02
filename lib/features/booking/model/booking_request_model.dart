class BookingRequestModel {
  final String service;
  final String details;
  final List<String> subServices;
  final LocationModel location;
  final ScheduleModel schedule;
  final int maxLimit;

  BookingRequestModel({
    required this.service,
    required this.details,
    required this.subServices,
    required this.location,
    required this.schedule,
    required this.maxLimit,
  });

  Map<String, dynamic> toJson() {
    return {
      "service": service,
      "details": details,
      "subServices": subServices,
      "location": location.toJson(),
      "schedule": schedule.toJson(),
      "maxLimit": maxLimit,
    };
  }
}

class LocationModel {
  final String address;
  final String city;
  final double? lat;
  final double? lng;
  final String? district;

  LocationModel({
    required this.address,
    required this.city,
    this.lat,
    this.lng,
    this.district,
  });

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "city": city,
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