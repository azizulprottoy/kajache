/// =============================
/// BOOKING REPOSITORY
/// =============================

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../model/booking_request_model.dart';

class BookingRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  BookingRepository({Dio? dio, NetworkInfo? networkInfo})
    : _dio = dio ?? ApiClient.instance,
      _networkInfo = networkInfo ?? NetworkInfo();

  Future<Map<String, dynamic>> createBooking(
    BookingRequestModel request,
  ) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection');
    }

    final response = await _dio.post(
      ApiEndpoints.booking,
      data: request.toJson(),
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> confirmPayment(String bookingId) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection');
    }

    final response = await _dio.post(ApiEndpoints.payment(bookingId));

    return Map<String, dynamic>.from(response.data);
  }
}
