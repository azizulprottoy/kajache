import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../../home/models/services_response_model.dart';
import '../model/service_details_response_model.dart';

class ServiceDetailsRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  ServiceDetailsRepository({Dio? dio, NetworkInfo? networkInfo})
    : _dio = dio ?? ApiClient.instance,
      _networkInfo = networkInfo ?? NetworkInfo();

  Future<ServiceModel?> getServiceBySlug(String slug) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.get(ApiEndpoints.serviceByslug(slug));

    final result = ServiceDetailsResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return result.data;
  }

  Future<void> placeBid({
    required String bookingId,
    required double price,
    required String estimatedArrival,
    String message = '',
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    await _dio.post(
      ApiEndpoints.placeBid(bookingId),
      data: {
        'price': price,
        'estimatedArrival': estimatedArrival,
        if (message.isNotEmpty) 'message': message,
      },
    );
  }
}
