import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../models/banner_response_model.dart';
import '../models/category_response_model.dart';
import '../models/services_response_model.dart';

class HomeRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  HomeRepository({
    Dio? dio,
    NetworkInfo? networkInfo,
  })  : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<List<AppBannerModel>> getBanners() async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.get(ApiEndpoints.banner);

    final result = BannerResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return result.data;
  }

  Future<List<CategoryModel>> getCategories() async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.get(ApiEndpoints.categories);

    final result = CategoryResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return result.data;
  }

  /// Services for the home page; [limit] caps how many the API sends.
  Future<List<ServiceModel>> getServices({int? limit}) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.get(
      ApiEndpoints.services,
      queryParameters: limit != null ? {'limit': limit} : null,
    );

    final result = ServiceResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return result.data;
  }
}