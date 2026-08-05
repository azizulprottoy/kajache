import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../../home/models/available_booking_response_model.dart';
import '../model/my_booking_model.dart';

class MyBookingRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  MyBookingRepository({
    Dio? dio,
    NetworkInfo? networkInfo,
  })  : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<List<MyBookingModel>> getMyBookings() async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection');
    }

    final response = await _dio.get(
      ApiEndpoints.myBookings,
    );

    final json = Map<String, dynamic>.from(response.data);

    final List bookings = json['data'] ?? [];

    return bookings
        .map(
          (e) => MyBookingModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  Future<AvailableBookingModel> getBooking(String bookingId) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection');
    }

    final response = await _dio.get(
      ApiEndpoints.bookingById(bookingId),
    );

    final json = Map<String, dynamic>.from(response.data);

    if (json['data'] is! Map) {
      throw Exception('Invalid booking response');
    }

    return AvailableBookingModel.fromJson(
      Map<String, dynamic>.from(json['data']),
    );
  }

  Future<void> selectBid({
    required String bookingId,
    required String bidId,
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection');
    }

    await _dio.post(
      ApiEndpoints.selectBid(bookingId),
      data: {'bidId': bidId},
    );
  }

  /// Pays the booking fee once a bid has been selected. Backend only
  /// accepts this once the booking is in 'bid_selected' state.
  Future<void> confirmPayment(
    String bookingId, {
    required String paymentMethod,
    required String transactionId,
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection');
    }

    await _dio.post(
      ApiEndpoints.payment(bookingId),
      data: {
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
      },
    );
  }

  Future<void> completeBooking(String bookingId) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection');
    }

    await _dio.post(
      ApiEndpoints.completeBooking(bookingId),
    );
  }

  Future<void> submitServiceReview({
    required String bookingId,
    required int rating,
    required String review,
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection');
    }

    await _dio.post(
      ApiEndpoints.review,
      data: {
        'booking': bookingId,
        'rating': rating,
        'review': review,
      },
    );
  }

  Future<void> submitProviderRating({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection');
    }

    await _dio.post(
      ApiEndpoints.employeeRating,
      data: {
        'booking': bookingId,
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      },
    );
  }

  Future<void> submitComplaint({
    required String complainAgainst,
    required String title,
    required String reason,
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection');
    }

    await _dio.post(
      ApiEndpoints.complain,
      data: {
        'complainAgainst': complainAgainst,
        'title': title.trim(),
        'reason': reason.trim(),
      },
    );
  }

  Future<void> cancelBid(String bookingId, {String reason = ''}) async {
    if (!await _networkInfo.isConnected) throw Exception('No internet connection');
    await _dio.post(ApiEndpoints.customerCancelBid(bookingId),
        data: {'reason': reason});
  }
}
