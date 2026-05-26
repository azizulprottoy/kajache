import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../../home/models/category_response_model.dart';
import '../model/Category_details_response_model.dart';

class CategoryDetailsRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  CategoryDetailsRepository({
    Dio? dio,
    NetworkInfo? networkInfo,
  })  : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<CategoryModel?> getCategoryById(String id) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.get(
      ApiEndpoints.categoryById(id),
    );

    final result = CategoryDetailsResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return result.data;
  }
}