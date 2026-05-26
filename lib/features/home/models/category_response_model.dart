import '../../../core/utils/media_url_helper.dart';

class CategoryResponseModel {
  final bool success;
  final int count;
  final List<CategoryModel> data;

  CategoryResponseModel({
    required this.success,
    required this.count,
    required this.data,
  });

  factory CategoryResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoryResponseModel(
      success: json['success'] == true,
      count: json['count'] ?? 0,
      data: json['data'] is List
          ? (json['data'] as List)
          .map((item) => CategoryModel.fromJson(
        Map<String, dynamic>.from(item),
      ))
          .toList()
          : [],
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String imageLink;
  final int clicks;
  final String createdAt;
  final String updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.imageLink,
    required this.clicks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageLink: MediaUrlHelper.resolve(json['imageLink']?.toString()),
      clicks: json['clicks'] ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}