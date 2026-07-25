import '../../../core/utils/media_url_helper.dart';

class PortfolioItem {
  final String id;
  final String technitianId;
  final String technitianName;
  final String image;
  final String servicedetails;

  const PortfolioItem({
    required this.id,
    required this.technitianId,
    required this.technitianName,
    required this.image,
    required this.servicedetails,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: (json['_id'] ?? json['id'] ?? json['technitianId'] ?? '').toString(),
      technitianId: (json['technitianId'] ?? '').toString(),
      technitianName: (json['technitianName'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      servicedetails: (json['servicedetails'] ?? '').toString(),
    );
  }

  String get imageUrl => MediaUrlHelper.resolve(image);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'technitianId': technitianId,
      'technitianName': technitianName,
      'image': image,
      'servicedetails': servicedetails,
    };
  }

  PortfolioItem copyWith({
    String? id,
    String? technitianId,
    String? technitianName,
    String? image,
    String? servicedetails,
  }) {
    return PortfolioItem(
      id: id ?? this.id,
      technitianId: technitianId ?? this.technitianId,
      technitianName: technitianName ?? this.technitianName,
      image: image ?? this.image,
      servicedetails: servicedetails ?? this.servicedetails,
    );
  }
}
