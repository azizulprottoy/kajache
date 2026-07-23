/// Models for the technician "available bookings" feed.
///
/// Backend: GET /api/v1/booking/available
/// Returns open bookings (status `bidding_open`) whose service category
/// matches the logged-in technician's skills, so the provider can bid on them.

/// Aggregated technician dashboard payload.
///
/// Backend: GET /api/v1/booking/provider/dashboard
/// Wraps `{ success, data: { stats, availableJobs } }`.
class SHomeDashboardModel {
  final bool success;
  final SHomeStatsModel stats;
  final List<AvailableBookingModel> availableJobs;

  SHomeDashboardModel({
    required this.success,
    required this.stats,
    required this.availableJobs,
  });

  factory SHomeDashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'])
        : <String, dynamic>{};

    return SHomeDashboardModel(
      success: json['success'] == true,
      stats: SHomeStatsModel.fromJson(
        data['stats'] is Map
            ? Map<String, dynamic>.from(data['stats'])
            : <String, dynamic>{},
      ),
      availableJobs: data['availableJobs'] is List
          ? (data['availableJobs'] as List)
              .map((item) => AvailableBookingModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
          : [],
    );
  }
}

/// Overview counters shown on the technician dashboard.
class SHomeStatsModel {
  final int available;
  final int activeBids;
  final int ongoing;
  final int completed;
  final int earnings;

  SHomeStatsModel({
    required this.available,
    required this.activeBids,
    required this.ongoing,
    required this.completed,
    required this.earnings,
  });

  factory SHomeStatsModel.fromJson(Map<String, dynamic> json) {
    int parse(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;
    return SHomeStatsModel(
      available: parse(json['available']),
      activeBids: parse(json['activeBids']),
      ongoing: parse(json['ongoing']),
      completed: parse(json['completed']),
      earnings: parse(json['earnings']),
    );
  }
}

class AvailableBookingResponseModel {
  final bool success;
  final int count;
  final List<AvailableBookingModel> data;

  AvailableBookingResponseModel({
    required this.success,
    required this.count,
    required this.data,
  });

  factory AvailableBookingResponseModel.fromJson(Map<String, dynamic> json) {
    return AvailableBookingResponseModel(
      success: json['success'] == true,
      count: json['count'] ?? 0,
      data: json['data'] is List
          ? (json['data'] as List)
              .map((item) => AvailableBookingModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
          : [],
    );
  }
}

class AvailableBookingModel {
  final String id;
  final String serviceId;
  final String serviceTitle;
  final String serviceSlug;
  final String clientName;
  final String details;
  final List<String> subServices;
  final String address;
  final String district;
  final String scheduleDate;
  final String scheduleTime;
  final int minLimit;
  final int bookingFee;
  final int bidsCount;
  final String status;
  final String paymentStatus;
  final String orderNumber;
  final String createdAt;
  final bool hasBid;
  final int? myBidPrice;
  final String? myBidStatus;

  AvailableBookingModel({
    required this.id,
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceSlug,
    required this.clientName,
    required this.details,
    required this.subServices,
    required this.address,
    required this.district,
    required this.scheduleDate,
    required this.scheduleTime,
    required this.minLimit,
    required this.bookingFee,
    required this.bidsCount,
    required this.status,
    required this.paymentStatus,
    required this.orderNumber,
    required this.createdAt,
    this.hasBid = false,
    this.myBidPrice,
    this.myBidStatus,
  });

  factory AvailableBookingModel.fromJson(Map<String, dynamic> json) {
    // `service` is populated to { _id, title, slug, category }
    final service = json['service'] is Map
        ? Map<String, dynamic>.from(json['service'])
        : <String, dynamic>{};

    // `client` is populated to { _id, username }
    final client = json['client'] is Map
        ? Map<String, dynamic>.from(json['client'])
        : <String, dynamic>{};

    // `location` is an embedded object { address, city, district, coordinates }
    final location = json['location'] is Map
        ? Map<String, dynamic>.from(json['location'])
        : <String, dynamic>{};

    // `schedule` is an embedded object { date, time }
    final schedule = json['schedule'] is Map
        ? Map<String, dynamic>.from(json['schedule'])
        : <String, dynamic>{};

    final myBid = json['myBid'] is Map
        ? Map<String, dynamic>.from(json['myBid'])
        : null;

    return AvailableBookingModel(
      id: json['_id']?.toString() ?? '',
      serviceId: service['_id']?.toString() ?? '',
      serviceTitle: service['title']?.toString() ?? 'Service',
      serviceSlug: service['slug']?.toString() ?? '',
      clientName: client['username']?.toString() ?? 'Customer',
      details: json['details']?.toString() ?? '',
      subServices: json['subServices'] is List
          ? (json['subServices'] as List).map((e) => e.toString()).toList()
          : const [],
      address: location['address']?.toString() ?? '',
      district: (location['district'] ?? json['district'])?.toString() ?? '',
      scheduleDate: schedule['date']?.toString() ?? '',
      scheduleTime: schedule['time']?.toString() ?? '',
      minLimit: int.tryParse(json['minLimit']?.toString() ?? '0') ?? 0,
      bookingFee: int.tryParse(json['bookingFee']?.toString() ?? '0') ?? 0,
      bidsCount: int.tryParse(json['bidsCount']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      hasBid: json['hasBid'] == true,
      myBidPrice: myBid != null
          ? int.tryParse(myBid['price']?.toString() ?? '')
          : null,
      myBidStatus: myBid?['status']?.toString(),
    );
  }

  /// Whether any provider has already bid on this job.
  bool get hasBids => bidsCount > 0;

  /// Human-facing budget label, e.g. "৳500".
  String get budgetLabel => '৳$minLimit';
}
