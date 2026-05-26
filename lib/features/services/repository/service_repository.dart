import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../../home/models/services_response_model.dart';

class AllServicesRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  AllServicesRepository({
    Dio? dio,
    NetworkInfo? networkInfo,
  })  : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<List<ServiceModel>> getAllServices() async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.get(ApiEndpoints.services);

    final result = ServiceResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return result.data;
  }
}