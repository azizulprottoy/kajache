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

  /// Pays the system fee that moves a draft booking to `bidding_open`.
  Future<Map<String, dynamic>> paySystemFee(
    String bookingId, {
    required String paymentMethod,
    String transactionId = '',
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection');
    }

    final response = await _dio.post(
      ApiEndpoints.paySystemFee(bookingId),
      data: {
        'paymentMethod': paymentMethod,
        if (transactionId.isNotEmpty) 'transactionId': transactionId,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }
}
