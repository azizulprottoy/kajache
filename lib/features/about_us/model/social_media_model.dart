import '../../../core/utils/media_url_helper.dart';

class SocialMediaModel {
  final String id;
  final String name;
  final String image;
  final int order;
  final String url;

  SocialMediaModel({
    required this.id,
    required this.name,
    required this.image,
    required this.order,
    required this.url,
  });

  factory SocialMediaModel.fromJson(Map<String, dynamic> json) {
    return SocialMediaModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: MediaUrlHelper.resolve(json['image']?.toString() ?? ''),
      order: int.tryParse(json['order']?.toString() ?? '0') ?? 0,
      url: json['url']?.toString() ?? '',
    );
  }
}
