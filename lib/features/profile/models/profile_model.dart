import '../../../core/utils/media_url_helper.dart';

class ProfileModel {
  final String id;
  final String email;
  final String username;
  final String roleModelName;
  final Map<String, dynamic> detail; // profileDetail
  final int points;

  ProfileModel({
    required this.id,
    required this.email,
    required this.username,
    required this.roleModelName,
    required this.detail,
    required this.points,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> data) {
    return ProfileModel(
      id: data['_id']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      roleModelName: data['roleModelName']?.toString() ?? '',
      detail: data['profileDetail'] is Map
          ? Map<String, dynamic>.from(data['profileDetail'])
          : <String, dynamic>{},
      points: (data['points'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isServiceProvider => roleModelName == 'TechnicianProfile';
  bool get isAdmin => roleModelName == 'AdminProfile';

  // ── Common ──
  String get fullName => (detail['fullName']?.toString().isNotEmpty ?? false)
      ? detail['fullName'].toString()
      : username;

  String get avatar => MediaUrlHelper.resolve(detail['avatar']?.toString());

  String get phone =>
      detail['phone']?.toString() ?? detail['phoneNumber']?.toString() ?? '';

  // Address may be a plain string (once you add it) or the current nested shape.
  String get address {
    final a = detail['address'];
    if (a is String) return a;
    if (a is Map) return a['street']?.toString() ?? '';
    final loc = detail['location'];
    if (loc is Map) return loc['address']?.toString() ?? '';
    return '';
  }

  String get district => detail['district']?.toString() ?? '';
  String get area => detail['area']?.toString() ?? '';

  // ── Service provider ──
  String get businessName => detail['businessName']?.toString() ?? '';

  String get category {
    if (detail['category'] != null) return detail['category'].toString();
    return skills.isNotEmpty ? skills.join(', ') : '';
  }

  String get experience {
    if (detail['experience'] != null) return detail['experience'].toString();
    final y = detail['experienceYears'];
    return y != null ? '$y years' : '';
  }

  String get serviceArea {
    if (detail['serviceArea'] != null) return detail['serviceArea'].toString();
    final loc = detail['location'];
    if (loc is Map) return loc['city']?.toString() ?? '';
    return '';
  }

  List<String> get skills =>
      (detail['skills'] as List?)?.map((e) => e.toString()).toList() ?? [];

  num get rating => detail['rating'] ?? 0;
  int get totalJobsCompleted => detail['totalJobsCompleted'] ?? 0;

  // ── Buyer ──
  num get totalSpent => detail['totalSpent'] ?? 0;
  int get jobPostCount => detail['jobPostCount'] ?? 0;
  num get trustScore => detail['trustScore'] ?? 0;
}