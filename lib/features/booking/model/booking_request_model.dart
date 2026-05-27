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

  LocationModel({
    required this.address,
    required this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "city": city,
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