import '../../../core/utils/media_url_helper.dart';

class ServiceResponseModel {
  final bool success;
  final int count;
  final List<ServiceModel> data;

  ServiceResponseModel({
    required this.success,
    required this.count,
    required this.data,
  });

  factory ServiceResponseModel.fromJson(Map<String, dynamic> json) {
    return ServiceResponseModel(
      success: json['success'] == true,
      count: json['count'] ?? 0,
      data: json['data'] is List
          ? (json['data'] as List)
          .map((item) => ServiceModel.fromJson(
        Map<String, dynamic>.from(item),
      ))
          .toList()
          : [],
    );
  }
}

class ServiceModel {
  final String id;
  final String title;
  final String slug;
  final String description;
  final double basePrice;
  final String status;
  final List<String> features;
  final CreatedByModel? createdBy;
  final String createdAt;
  final String updatedAt;
  final String imageLink;


  ServiceModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.basePrice,
    required this.status,
    required this.features,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.imageLink,

  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      basePrice: double.tryParse(json['basePrice']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? '',
      features: json['features'] is List
          ? (json['features'] as List).map((e) => e.toString()).toList()
          : [],
      createdBy: json['createdBy'] != null
          ? CreatedByModel.fromJson(
        Map<String, dynamic>.from(json['createdBy']),
      )
          : null,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      imageLink: MediaUrlHelper.resolve(json['imageLink']?.toString()),

    );
  }
}

class CreatedByModel {
  final String id;
  final String email;
  final String username;

  CreatedByModel({
    required this.id,
    required this.email,
    required this.username,
  });

  factory CreatedByModel.fromJson(Map<String, dynamic> json) {
    return CreatedByModel(
      id: json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }
}