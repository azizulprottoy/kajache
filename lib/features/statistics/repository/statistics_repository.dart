import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../../home/models/available_booking_response_model.dart';

class StatisticsRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  StatisticsRepository({
    Dio? dio,
    NetworkInfo? networkInfo,
  })  : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<void> _requireConnection() async {
    if (!await _networkInfo.isConnected) {
      throw Exception('No internet connection.');
    }
  }

  Future<List<ProviderBidModel>> getAcceptedBookings() async {
    await _requireConnection();

    final response = await _dio.get(ApiEndpoints.providerBids);
    final payload = Map<String, dynamic>.from(response.data);
    final data = payload['data'] is List ? payload['data'] as List : const [];

    return data
        .whereType<Map>()
        .map(
          (item) => ProviderBidModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (bid) {
            final bidStatus = bid.status.trim().toLowerCase();
            final bookingStatus =
                bid.bookingStatus.trim().toLowerCase();

            return bidStatus == 'selected' &&
                (bookingStatus == 'bid_selected' ||
                    bookingStatus == 'in_progress');
          },
        )
        .toList();
  }

  Future<void> makeBookingInProgress(String bookingId) async {
    await _requireConnection();
    await _dio.post(ApiEndpoints.acceptBooking(bookingId));
  }
}
