import '../../home/models/category_response_model.dart';

class CategoryDetailsResponseModel {
  final bool success;
  final CategoryModel? data;

  CategoryDetailsResponseModel({
    required this.success,
    this.data,
  });

  factory CategoryDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoryDetailsResponseModel(
      success: json['success'] == true,
      data: json['data'] != null
          ? CategoryModel.fromJson(
        Map<String, dynamic>.from(json['data']),
      )
          : null,
    );
  }
}