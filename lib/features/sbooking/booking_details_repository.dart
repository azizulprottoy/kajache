import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/network_info.dart';
import '../home/models/available_booking_response_model.dart';

class BookingDetailsRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  BookingDetailsRepository({Dio? dio, NetworkInfo? networkInfo})
      : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<void> _requireConnection() async {
    if (!await _networkInfo.isConnected) {
      throw Exception('No internet connection.');
    }
  }

  Future<AvailableBookingModel> getBooking(String bookingId) async {
    await _requireConnection();
    final response = await _dio.get(ApiEndpoints.bookingById(bookingId));
    final payload = Map<String, dynamic>.from(response.data);
    return AvailableBookingModel.fromJson(
      Map<String, dynamic>.from(payload['data']),
    );
  }

  Future<ProviderBidModel> placeBid({
    required String bookingId,
    required double price,
    required String estimatedArrival,
    required String message,
  }) async {
    await _requireConnection();
    final response = await _dio.post(
      ApiEndpoints.placeBid(bookingId),
      data: {
        'price': price,
        'estimatedArrival': estimatedArrival,
        'message': message,
      },
    );
    final payload = Map<String, dynamic>.from(response.data);
    return ProviderBidModel.fromJson(
      Map<String, dynamic>.from(payload['data']),
    );
  }

  Future<ProviderBidModel> updateBid({
    required String bookingId,
    required String bidId,
    required double price,
    required String estimatedArrival,
    required String message,
  }) async {
    await _requireConnection();
    final response = await _dio.put(
      ApiEndpoints.updateBid(bookingId, bidId),
      data: {
        'price': price,
        'estimatedArrival': estimatedArrival,
        'message': message,
      },
    );
    final payload = Map<String, dynamic>.from(response.data);
    return ProviderBidModel.fromJson(
      Map<String, dynamic>.from(payload['data']),
    );
  }

  Future<void> markCashReceived(String bookingId) async {
    await _requireConnection();
    await _dio.post(ApiEndpoints.markCashReceived(bookingId));
  }

  Future<void> cancelBid(String bookingId, {String reason = ''}) async {
    await _requireConnection();
    await _dio.post(ApiEndpoints.technicianCancelBid(bookingId),
        data: {'reason': reason});
  }

  Future<void> respondReassignment(String bookingId, {required bool accept}) async {
    await _requireConnection();
    await _dio.post(ApiEndpoints.respondReassignment(bookingId),
        data: {'accept': accept});
  }
}
