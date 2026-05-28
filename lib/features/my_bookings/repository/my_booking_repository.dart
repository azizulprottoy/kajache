import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
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
}