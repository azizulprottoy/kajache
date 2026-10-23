// Models for the "Recruitment Request" feature.
//
// Backend: /api/v1/recruitmentRequest
// Difference from Booking / Instant Service: the platform fee is paid
// UPFRONT to post the job (status starts as `pending_payment`); paying it
// transitions the request to `hiring_open`, which is when technicians can
// start applying/bidding. There is no separate "technician accepts" step —
// picking an applicant ("select-bid") immediately transitions to `hired`.

import '../../../core/utils/localized_text.dart';
import '../../../core/utils/money_format.dart';

/// Readable category name; a bare (unpopulated) ObjectId gives ''.
String _categoryName(dynamic category) {
  if (category is! Map) return '';
  return LocalizedText.pick(
    (category['name'] ?? category['title'] ?? '').toString(),
    category['nameBn']?.toString(),
  );
}

/// Summary/list item — used for `GET /recruitmentRequest/me`.
class RecruitmentRequestModel {
  final String id;
  final String clientId;

  final String title;
  final String image;
  final String details;
  final String category;

  final String duration;
  final num salary;

  final String address;
  final String city;
  final String district;
  final String area;

  final int bidsCount;
  final int platformFee;

  final String paymentStatus;
  final String status;

  final String? cancellationReason;
  final String? endedAt;
  final String? paymentMethod;
  final String? transactionId;

  /// Only on `/available`: whether this technician already applied.
  final bool hasBid;
  final RecruitmentBidModel? myBid;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RecruitmentRequestModel({
    required this.id,
    required this.clientId,
    required this.title,
    required this.image,
    required this.details,
    required this.category,
    required this.duration,
    required this.salary,
    required this.address,
    required this.city,
    required this.district,
    this.area = '',
    required this.bidsCount,
    required this.platformFee,
    required this.paymentStatus,
    required this.status,
    this.cancellationReason,
    this.endedAt,
    this.paymentMethod,
    this.transactionId,
    this.hasBid = false,
    this.myBid,
    this.createdAt,
    this.updatedAt,
  });

  factory RecruitmentRequestModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] is Map
        ? Map<String, dynamic>.from(json['location'] as Map)
        : <String, dynamic>{};

    final rawClient = json['client'];
    final client = rawClient is Map
        ? Map<String, dynamic>.from(rawClient)
        : <String, dynamic>{};

    return RecruitmentRequestModel(
      id: json['_id']?.toString() ?? '',
      clientId: client.isNotEmpty
          ? client['_id']?.toString() ?? ''
          : rawClient?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      category: _categoryName(json['category']),
      duration: json['duration']?.toString() ?? '',
      salary: num.tryParse(json['salary']?.toString() ?? '0') ?? 0,
      address: location['address']?.toString() ?? '',
      city: location['city']?.toString() ?? '',
      district: location['district']?.toString() ?? '',
      area: location['area']?.toString() ?? '',
      bidsCount: int.tryParse(json['bidsCount']?.toString() ?? '0') ?? 0,
      platformFee: int.tryParse(json['platformFee']?.toString() ?? '300') ?? 300,
      paymentStatus: json['paymentStatus']?.toString() ?? 'unpaid',
      status: json['status']?.toString() ?? 'pending_payment',
      cancellationReason: json['cancellationReason']?.toString(),
      endedAt: json['endedAt']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      transactionId: json['transactionId']?.toString(),
      hasBid: json['hasBid'] == true || json['myBid'] is Map,
      myBid: json['myBid'] is Map
          ? RecruitmentBidModel.fromJson(Map<String, dynamic>.from(json['myBid'] as Map))
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  String get locationText =>
      [address, area, district, city].where((v) => v.trim().isNotEmpty).join(', ');

  String get salaryLabel => formatTaka(salary);
}

/// Full details payload — used for `GET /recruitmentRequest/:id`.
/// Adds the `bids` list plus `hasBid`/`myBid` (relevant for the technician
/// viewing a posting they may have already applied to).
class RecruitmentRequestDetailsModel {
  final String id;
  final String clientId;

  final String title;
  final String image;
  final String details;
  final String category;

  final String duration;
  final num salary;

  final String address;
  final String city;
  final String district;
  final String area;

  final int bidsCount;
  final int platformFee;

  final String paymentStatus;
  final String status;

  final String? cancellationReason;
  final String? endedAt;
  final String? paymentMethod;
  final String? transactionId;
  final String? selectedBidId;

  final List<RecruitmentBidModel> bids;
  final bool hasBid;
  final RecruitmentBidModel? myBid;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RecruitmentRequestDetailsModel({
    required this.id,
    required this.clientId,
    required this.title,
    required this.image,
    required this.details,
    required this.category,
    required this.duration,
    required this.salary,
    required this.address,
    required this.city,
    required this.district,
    this.area = '',
    required this.bidsCount,
    required this.platformFee,
    required this.paymentStatus,
    required this.status,
    this.cancellationReason,
    this.endedAt,
    this.paymentMethod,
    this.transactionId,
    this.selectedBidId,
    this.bids = const [],
    this.hasBid = false,
    this.myBid,
    this.createdAt,
    this.updatedAt,
  });

  factory RecruitmentRequestDetailsModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] is Map
        ? Map<String, dynamic>.from(json['location'] as Map)
        : <String, dynamic>{};

    final rawClient = json['client'];
    final client = rawClient is Map
        ? Map<String, dynamic>.from(rawClient)
        : <String, dynamic>{};

    final myBidJson = json['myBid'] is Map
        ? Map<String, dynamic>.from(json['myBid'] as Map)
        : null;

    final rawSelectedBid = json['selectedBid'];
    final selectedBidId = rawSelectedBid is Map
        ? rawSelectedBid['_id']?.toString()
        : rawSelectedBid?.toString();

    return RecruitmentRequestDetailsModel(
      id: json['_id']?.toString() ?? '',
      clientId: client.isNotEmpty
          ? client['_id']?.toString() ?? ''
          : rawClient?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      category: _categoryName(json['category']),
      duration: json['duration']?.toString() ?? '',
      salary: num.tryParse(json['salary']?.toString() ?? '0') ?? 0,
      address: location['address']?.toString() ?? '',
      city: location['city']?.toString() ?? '',
      district: location['district']?.toString() ?? '',
      area: location['area']?.toString() ?? '',
      bidsCount: int.tryParse(json['bidsCount']?.toString() ?? '0') ??
          (json['bids'] is List ? (json['bids'] as List).length : 0),
      platformFee: int.tryParse(json['platformFee']?.toString() ?? '300') ?? 300,
      paymentStatus: json['paymentStatus']?.toString() ?? 'unpaid',
      status: json['status']?.toString() ?? 'pending_payment',
      cancellationReason: json['cancellationReason']?.toString(),
      endedAt: json['endedAt']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      transactionId: json['transactionId']?.toString(),
      selectedBidId: selectedBidId,
      bids: json['bids'] is List
          ? (json['bids'] as List)
              .whereType<Map>()
              .map((e) => RecruitmentBidModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : const [],
      hasBid: json['hasBid'] == true || myBidJson != null,
      myBid: myBidJson != null
          ? RecruitmentBidModel.fromJson(myBidJson)
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  String get locationText =>
      [address, area, district, city].where((v) => v.trim().isNotEmpty).join(', ');

  String get salaryLabel => formatTaka(salary);

  bool get isPaymentDue =>
      status.trim().toLowerCase() == 'pending_payment' &&
      paymentStatus.trim().toLowerCase() != 'paid';
}

/// A technician's application ("bid") on a recruitment request.
class RecruitmentBidModel {
  final String id;

  final String applicantId;
  final String applicantUsername;
  final String applicantRoleModelName;
  final String applicantName;
  final String applicantAvatar;
  final double applicantRating;
  final int applicantTotalJobsCompleted;

  final num proposedSalary;
  final String message;
  final String status;

  final DateTime? createdAt;

  const RecruitmentBidModel({
    required this.id,
    required this.applicantId,
    required this.applicantUsername,
    required this.applicantRoleModelName,
    required this.applicantName,
    required this.applicantAvatar,
    required this.applicantRating,
    required this.applicantTotalJobsCompleted,
    required this.proposedSalary,
    required this.message,
    required this.status,
    this.createdAt,
  });

  factory RecruitmentBidModel.fromJson(Map<String, dynamic> json) {
    final applicant = json['applicant'] is Map
        ? Map<String, dynamic>.from(json['applicant'] as Map)
        : <String, dynamic>{};

    final profile = applicant['profileDetail'] is Map
        ? Map<String, dynamic>.from(applicant['profileDetail'] as Map)
        : <String, dynamic>{};

    final fullName = profile['fullName']?.toString().trim() ?? '';
    final username = applicant['username']?.toString().trim() ?? '';

    return RecruitmentBidModel(
      id: json['_id']?.toString() ?? '',
      applicantId: applicant['_id']?.toString() ?? '',
      applicantUsername: username,
      applicantRoleModelName: applicant['roleModelName']?.toString() ?? '',
      applicantName: fullName.isNotEmpty
          ? fullName
          : (username.isNotEmpty ? username : 'Technician'),
      applicantAvatar: profile['avatar']?.toString() ?? '',
      applicantRating:
          double.tryParse(profile['rating']?.toString() ?? '0') ?? 0.0,
      applicantTotalJobsCompleted:
          int.tryParse(profile['totalJobsCompleted']?.toString() ?? '0') ?? 0,
      proposedSalary:
          num.tryParse(json['proposedSalary']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  String get proposedSalaryLabel => formatTaka(proposedSalary);
}

/// One of the technician's own applications, from
/// `GET /recruitmentRequest/provider/bids`, with a summary of the job post.
class RecruitmentApplicationModel {
  final RecruitmentBidModel bid;
  final RecruitmentRequestModel request;

  const RecruitmentApplicationModel({required this.bid, required this.request});

  factory RecruitmentApplicationModel.fromJson(Map<String, dynamic> json) {
    final request = json['recruitmentRequest'] is Map
        ? Map<String, dynamic>.from(json['recruitmentRequest'] as Map)
        : <String, dynamic>{'_id': json['recruitmentRequest']?.toString() ?? ''};

    return RecruitmentApplicationModel(
      bid: RecruitmentBidModel.fromJson(json),
      request: RecruitmentRequestModel.fromJson(request),
    );
  }
}
