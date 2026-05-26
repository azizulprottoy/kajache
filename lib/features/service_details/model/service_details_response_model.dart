import '../../home/models/services_response_model.dart';

class ServiceDetailsResponseModel {
  final bool success;
  final ServiceModel? data;

  ServiceDetailsResponseModel({
    required this.success,
    this.data,
  });

  factory ServiceDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsResponseModel(
      success: json['success'] == true,
      data: json['data'] != null
          ? ServiceModel.fromJson(
        Map<String, dynamic>.from(json['data']),
      )
          : null,
    );
  }
}