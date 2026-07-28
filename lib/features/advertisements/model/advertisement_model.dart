import '../../../core/utils/media_url_helper.dart';

class AdvertisementModel {
  final String id;
  final String name;
  final String device;
  final String position;
  final int order;
  final String imageMobile;
  final String imageDesktop;
  final DateTime? startDate;
  final DateTime? endDate;

  AdvertisementModel({
    required this.id,
    required this.name,
    required this.device,
    required this.position,
    required this.order,
    required this.imageMobile,
    required this.imageDesktop,
    this.startDate,
    this.endDate,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      device: json['device']?.toString() ?? 'both',
      position: json['position']?.toString() ?? '',
      order: int.tryParse(json['order']?.toString() ?? '0') ?? 0,
      imageMobile: MediaUrlHelper.resolve(json['imageMobile']?.toString() ?? ''),
      imageDesktop: MediaUrlHelper.resolve(json['imageDesktop']?.toString() ?? ''),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
    );
  }

  bool get isActive {
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  // Prefer mobile image on app, fall back to desktop
  String get imageUrl => imageMobile.isNotEmpty ? imageMobile : imageDesktop;

  bool get isForApp => device == 'app' || device == 'both';
}
