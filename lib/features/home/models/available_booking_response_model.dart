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
  final String serviceDescription;
  final String serviceImage;
  final JobPosterModel poster;
  final String details;
  final List<String> subServices;
  final List<BookingBidModel> bids;
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
  final String? myBidId;
  final int? myBidPrice;
  final String? myBidEstimatedArrival;
  final String? myBidMessage;
  final String? myBidStatus;

  AvailableBookingModel({
    required this.id,
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceSlug,
    required this.serviceDescription,
    required this.serviceImage,
    required this.poster,
    required this.details,
    required this.subServices,
    required this.bids,
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
    this.myBidId,
    this.myBidPrice,
    this.myBidEstimatedArrival,
    this.myBidMessage,
    this.myBidStatus,
  });

  factory AvailableBookingModel.fromJson(Map<String, dynamic> json) {
    // `service` is populated to { _id, title, slug, category }
    final service = json['service'] is Map
        ? Map<String, dynamic>.from(json['service'])
        : <String, dynamic>{};

    // `client` is populated with safe public poster profile details.
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

    String serviceImage() {
      for (final key in const ['image', 'imageLink']) {
        final value = service[key]?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }

      final images = service['images'];
      if (images is List && images.isNotEmpty) {
        final first = images.first;
        if (first is Map) {
          final image = Map<String, dynamic>.from(first);
          return (image['url'] ?? image['image'] ?? image['imageLink'])
                  ?.toString()
                  .trim() ??
              '';
        }
        return first?.toString().trim() ?? '';
      }
      return '';
    }

    return AvailableBookingModel(
      id: json['_id']?.toString() ?? '',
      serviceId: service['_id']?.toString() ?? '',
      serviceTitle: service['title']?.toString() ?? 'Service',
      serviceSlug: service['slug']?.toString() ?? '',
      serviceDescription:
          (service['description'] ?? service['shortDescription'])
                  ?.toString() ??
              '',
      serviceImage: serviceImage(),
      poster: JobPosterModel.fromJson(client),
      details: json['details']?.toString() ?? '',
      subServices: json['subServices'] is List
          ? (json['subServices'] as List).map((e) => e.toString()).toList()
          : const [],
      bids: json['bids'] is List
          ? (json['bids'] as List)
              .whereType<Map>()
              .map(
                (item) => BookingBidModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      address: location['address']?.toString() ?? '',
      district:
          (location['district'] ?? location['city'] ?? json['district'])
                  ?.toString() ??
              '',
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
      myBidId: myBid?['_id']?.toString(),
      myBidPrice: myBid != null
          ? int.tryParse(myBid['price']?.toString() ?? '')
          : null,
      myBidEstimatedArrival: myBid?['estimatedArrival']?.toString(),
      myBidMessage: myBid?['message']?.toString(),
      myBidStatus: myBid?['status']?.toString(),
    );
  }

  AvailableBookingModel withMyBid(ProviderBidModel bid) {
    return AvailableBookingModel(
      id: id,
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      serviceSlug: serviceSlug,
      serviceDescription: serviceDescription,
      serviceImage: serviceImage,
      poster: poster,
      details: details,
      subServices: subServices,
      bids: bids,
      address: address,
      district: district,
      scheduleDate: scheduleDate,
      scheduleTime: scheduleTime,
      minLimit: minLimit,
      bookingFee: bookingFee,
      bidsCount: bidsCount,
      status: status,
      paymentStatus: paymentStatus,
      orderNumber: orderNumber,
      createdAt: createdAt,
      hasBid: true,
      myBidId: bid.id,
      myBidPrice: bid.price,
      myBidEstimatedArrival: bid.estimatedArrival,
      myBidMessage: bid.message,
      myBidStatus: bid.status,
    );
  }

  /// Whether any provider has already bid on this job.
  bool get hasBids => bidsCount > 0;

  /// Human-facing budget label, e.g. "৳500".
  String get budgetLabel => '৳$minLimit';

  String get clientName => poster.name;
}

class BookingBidModel {
  final String id;

  final String providerId;
  final String providerUsername;
  final String providerName;
  final String providerAvatar;

  final int totalJobsCompleted;
  final double rating;

  final int price;
  final String estimatedArrival;
  final String message;
  final String status;

  const BookingBidModel({
    required this.id,
    required this.providerId,
    required this.providerUsername,
    required this.providerName,
    required this.providerAvatar,
    required this.totalJobsCompleted,
    required this.rating,
    required this.price,
    required this.estimatedArrival,
    required this.message,
    required this.status,
  });

  factory BookingBidModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] is Map
        ? Map<String, dynamic>.from(json['provider'])
        : <String, dynamic>{};

    final profile = provider['profileDetail'] is Map
        ? Map<String, dynamic>.from(provider['profileDetail'])
        : <String, dynamic>{};

    final fullName = profile['fullName']?.toString().trim() ?? '';
    final username = provider['username']?.toString().trim() ?? '';

    return BookingBidModel(
      id: json['_id']?.toString() ?? '',

      providerId: provider['_id']?.toString() ?? '',
      providerUsername: username,
      providerName: fullName.isNotEmpty
          ? fullName
          : (username.isNotEmpty ? username : 'Technician'),
      providerAvatar: profile['avatar']?.toString() ?? '',

      totalJobsCompleted:
      int.tryParse(profile['totalJobsCompleted']?.toString() ?? '0') ?? 0,

      rating:
      double.tryParse(profile['rating']?.toString() ?? '0') ?? 0.0,

      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      estimatedArrival: json['estimatedArrival']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}
class JobPosterModel {
  final String id;
  final String username;
  final String fullName;
  final String avatar;
  final String address;
  final String district;
  final String area;
  final int jobPostCount;
  final num trustScore;

  const JobPosterModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatar,
    required this.address,
    required this.district,
    required this.area,
    required this.jobPostCount,
    required this.trustScore,
  });

  factory JobPosterModel.fromJson(Map<String, dynamic> json) {
    final detail = json['profileDetail'] is Map
        ? Map<String, dynamic>.from(json['profileDetail'])
        : <String, dynamic>{};

    return JobPosterModel(
      id: json['_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: detail['fullName']?.toString() ?? '',
      avatar: detail['avatar']?.toString() ?? '',
      address: detail['address']?.toString() ?? '',
      district: detail['district']?.toString() ?? '',
      area: detail['area']?.toString() ?? '',
      jobPostCount:
      int.tryParse(detail['jobPostCount']?.toString() ?? '0') ?? 0,
      trustScore:
      num.tryParse(detail['trustScore']?.toString() ?? '0') ?? 0,
    );
  }

  String get name {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    if (username.trim().isNotEmpty) return username.trim();
    return 'Customer';
  }

  String get location =>
      [address, area, district]
          .where((value) => value.trim().isNotEmpty)
          .join(', ');
}

class ProviderBidModel {
  final String id;
  final String bookingId;
  final int? price;
  final String estimatedArrival;
  final String message;
  final String status;

  ProviderBidModel({
    required this.id,
    required this.bookingId,
    this.price,
    required this.estimatedArrival,
    required this.message,
    required this.status,
  });

  factory ProviderBidModel.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'];
    final bookingId = booking is Map
        ? booking['_id']?.toString() ?? ''
        : booking?.toString() ?? '';

    return ProviderBidModel(
      id: json['_id']?.toString() ?? '',
      bookingId: bookingId,
      price: int.tryParse(json['price']?.toString() ?? ''),
      estimatedArrival: json['estimatedArrival']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}
