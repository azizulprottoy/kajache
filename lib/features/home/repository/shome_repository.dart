import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../models/available_booking_response_model.dart';

/// Repository for the technician (service-provider) home dashboard.
///
/// Backed by GET /api/v1/booking/available — the list of open jobs the
/// logged-in technician is eligible to bid on.
class SHomeRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  SHomeRepository({
    Dio? dio,
    NetworkInfo? networkInfo,
  })  : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  /// Full technician dashboard: overview stats + available jobs, one call.
  Future<SHomeDashboardModel> getDashboard() async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final responses = await Future.wait([
      _dio.get(ApiEndpoints.providerDashboard),
      _dio.get(ApiEndpoints.providerBids),
    ]);

    final dashboard = SHomeDashboardModel.fromJson(
      Map<String, dynamic>.from(responses[0].data),
    );
    final bidsPayload = Map<String, dynamic>.from(responses[1].data);
    final bids = bidsPayload['data'] is List
        ? (bidsPayload['data'] as List)
        .map(
          (item) => ProviderBidModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList()
        : <ProviderBidModel>[];
    final bidsByBooking = {
      for (final bid in bids)
        if (bid.bookingId.isNotEmpty) bid.bookingId: bid,
    };

    return SHomeDashboardModel(
      success: dashboard.success,
      stats: dashboard.stats,
      availableJobs: dashboard.availableJobs.map((job) {
        final bid = bidsByBooking[job.id];
        return bid == null ? job : job.withMyBid(bid);
      }).toList(),
    );
  }

  Future<List<AvailableBookingModel>> getAvailableBookings() async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.get(ApiEndpoints.availableBookings);

    final result = AvailableBookingResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return result.data;
  }
}
