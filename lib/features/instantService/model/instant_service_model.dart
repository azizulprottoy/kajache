// Models for the "Instant Service" feature.
//
// Backend: /api/v1/instantService — ad-hoc jobs a customer posts, technicians
// bid on, the customer selects a winner, THEN pays a platform fee (payment
// happens after bid selection, not at creation), and finally the selected
// technician accepts to lock the job in progress.
//
// Mirrors the parsing style of
// `lib/features/home/models/available_booking_response_model.dart`
// (AvailableBookingModel / BookingBidModel) but renamed to InstantService's
// own field names (title/details/priceMin-priceMax instead of
// service/minLimit, no required schedule, etc).

class InstantServiceLocationModel {
  final String address;
  final String city;
  final String district;
  final double? lat;
  final double? lng;

  const InstantServiceLocationModel({
    required this.address,
    required this.city,
    required this.district,
    this.lat,
    this.lng,
  });

  factory InstantServiceLocationModel.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] is Map
        ? Map<String, dynamic>.from(json['coordinates'])
        : <String, dynamic>{};

    return InstantServiceLocationModel(
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      lat: (coordinates['lat'] as num?)?.toDouble(),
      lng: (coordinates['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      if (city.isNotEmpty) "city": city,
      if (district.isNotEmpty) "district": district,
      if (lat != null && lng != null) "coordinates": {"lat": lat, "lng": lng},
    };
  }
}

class InstantServiceScheduleModel {
  final String date;
  final String time;

  const InstantServiceScheduleModel({
    required this.date,
    required this.time,
  });

  factory InstantServiceScheduleModel.fromJson(Map<String, dynamic> json) {
    return InstantServiceScheduleModel(
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }

  bool get isEmpty => date.trim().isEmpty && time.trim().isEmpty;

  Map<String, dynamic> toJson() {
    return {
      if (date.trim().isNotEmpty) "date": date,
      if (time.trim().isNotEmpty) "time": time,
    };
  }
}

/// Public bidder/poster profile fragment shared by client & provider.
class InstantServiceProfileModel {
  final String id;
  final String username;
  final String fullName;
  final String avatar;
  final double rating;
  final int totalJobsCompleted;

  const InstantServiceProfileModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatar,
    required this.rating,
    required this.totalJobsCompleted,
  });

  factory InstantServiceProfileModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profileDetail'] is Map
        ? Map<String, dynamic>.from(json['profileDetail'])
        : <String, dynamic>{};

    final fullName = profile['fullName']?.toString().trim() ?? '';
    final username = json['username']?.toString().trim() ?? '';

    return InstantServiceProfileModel(
      id: json['_id']?.toString() ?? '',
      username: username,
      fullName: fullName,
      avatar: profile['avatar']?.toString() ?? '',
      rating: double.tryParse(profile['rating']?.toString() ?? '0') ?? 0.0,
      totalJobsCompleted:
          int.tryParse(profile['totalJobsCompleted']?.toString() ?? '0') ?? 0,
    );
  }

  String get name {
    if (fullName.isNotEmpty) return fullName;
    if (username.isNotEmpty) return username;
    return 'User';
  }
}

class InstantServiceBidModel {
  final String id;
  final String instantServiceId;
  final InstantServiceProfileModel provider;
  final int price;
  final String message;
  final String estimatedArrival;
  final String status;
  final String createdAt;

  const InstantServiceBidModel({
    required this.id,
    required this.instantServiceId,
    required this.provider,
    required this.price,
    required this.message,
    required this.estimatedArrival,
    required this.status,
    required this.createdAt,
  });

  factory InstantServiceBidModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] is Map
        ? Map<String, dynamic>.from(json['provider'])
        : <String, dynamic>{};

    return InstantServiceBidModel(
      id: json['_id']?.toString() ?? '',
      instantServiceId: json['instantService']?.toString() ?? '',
      provider: InstantServiceProfileModel.fromJson(provider),
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
      estimatedArrival: json['estimatedArrival']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

/// Summary shape used by `/instantService/me` and `/instantService/available`.
class InstantServiceModel {
  final String id;
  final String clientId;
  final String title;
  final String image;
  final String details;
  final String category;
  final int priceMin;
  final int priceMax;
  final InstantServiceLocationModel location;
  final InstantServiceScheduleModel schedule;
  final int bidsCount;
  final int platformFee;
  final String paymentStatus;
  final String status;
  final String? cancellationReason;
  final String? completedAt;
  final String? paymentMethod;
  final String? transactionId;
  final bool hasBid;
  final InstantServiceBidModel? myBid;
  final String createdAt;
  final String updatedAt;

  const InstantServiceModel({
    required this.id,
    required this.clientId,
    required this.title,
    required this.image,
    required this.details,
    required this.category,
    required this.priceMin,
    required this.priceMax,
    required this.location,
    required this.schedule,
    required this.bidsCount,
    required this.platformFee,
    required this.paymentStatus,
    required this.status,
    this.cancellationReason,
    this.completedAt,
    this.paymentMethod,
    this.transactionId,
    this.hasBid = false,
    this.myBid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InstantServiceModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] is Map
        ? Map<String, dynamic>.from(json['location'])
        : <String, dynamic>{};

    final schedule = json['schedule'] is Map
        ? Map<String, dynamic>.from(json['schedule'])
        : <String, dynamic>{};

    final myBid = json['myBid'] is Map
        ? Map<String, dynamic>.from(json['myBid'])
        : null;

    final category = json['category'];
    final categoryLabel = category is Map
        ? (category['title'] ?? category['name'] ?? category['_id'])
            ?.toString()
        : category?.toString();

    return InstantServiceModel(
      id: json['_id']?.toString() ?? '',
      clientId: json['client'] is Map
          ? Map<String, dynamic>.from(json['client'])['_id']?.toString() ?? ''
          : json['client']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      category: categoryLabel ?? '',
      priceMin: int.tryParse(json['priceMin']?.toString() ?? '0') ?? 0,
      priceMax: int.tryParse(json['priceMax']?.toString() ?? '0') ?? 0,
      location: InstantServiceLocationModel.fromJson(location),
      schedule: InstantServiceScheduleModel.fromJson(schedule),
      bidsCount: int.tryParse(json['bidsCount']?.toString() ?? '0') ?? 0,
      platformFee: int.tryParse(json['platformFee']?.toString() ?? '500') ?? 500,
      paymentStatus: json['paymentStatus']?.toString() ?? 'unpaid',
      status: json['status']?.toString() ?? 'bidding_open',
      cancellationReason: json['cancellationReason']?.toString(),
      completedAt: json['completedAt']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      transactionId: json['transactionId']?.toString(),
      hasBid: json['hasBid'] == true,
      myBid: myBid != null ? InstantServiceBidModel.fromJson(myBid) : null,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  /// Human-facing price range label, e.g. "৳500 - ৳1000".
  String get priceRangeLabel => '৳$priceMin - ৳$priceMax';
}

/// Full details shape returned by `/instantService/:id` — includes the bids
/// list on top of everything in [InstantServiceModel].
class InstantServiceDetailsModel extends InstantServiceModel {
  final List<InstantServiceBidModel> bids;

  const InstantServiceDetailsModel({
    required super.id,
    required super.clientId,
    required super.title,
    required super.image,
    required super.details,
    required super.category,
    required super.priceMin,
    required super.priceMax,
    required super.location,
    required super.schedule,
    required super.bidsCount,
    required super.platformFee,
    required super.paymentStatus,
    required super.status,
    super.cancellationReason,
    super.completedAt,
    super.paymentMethod,
    super.transactionId,
    super.hasBid,
    super.myBid,
    required super.createdAt,
    required super.updatedAt,
    required this.bids,
  });

  factory InstantServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    final base = InstantServiceModel.fromJson(json);

    final bids = json['bids'] is List
        ? (json['bids'] as List)
            .whereType<Map>()
            .map((e) => InstantServiceBidModel.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : <InstantServiceBidModel>[];

    return InstantServiceDetailsModel(
      id: base.id,
      clientId: base.clientId,
      title: base.title,
      image: base.image,
      details: base.details,
      category: base.category,
      priceMin: base.priceMin,
      priceMax: base.priceMax,
      location: base.location,
      schedule: base.schedule,
      bidsCount: base.bidsCount,
      platformFee: base.platformFee,
      paymentStatus: base.paymentStatus,
      status: base.status,
      cancellationReason: base.cancellationReason,
      completedAt: base.completedAt,
      paymentMethod: base.paymentMethod,
      transactionId: base.transactionId,
      hasBid: base.hasBid,
      myBid: base.myBid,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      bids: bids,
    );
  }

  /// The bid marked as `status == 'selected'`, if any.
  InstantServiceBidModel? get selectedBid {
    for (final bid in bids) {
      if (bid.status.trim().toLowerCase() == 'selected') return bid;
    }
    return null;
  }
}
