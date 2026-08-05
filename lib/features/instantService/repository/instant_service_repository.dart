// =============================
// INSTANT SERVICE REPOSITORY
// =============================
//
// Backend: /api/v1/instantService. Fee is paid AFTER a bid is selected
// (status `bid_selected`), unlike the old booking flow where payment was
// upfront. Mirrors `lib/features/booking/repository/booking_repository.dart`
// + `lib/features/my_bookings/repository/my_booking_repository.dart` +
// `lib/features/sbooking/booking_details_repository.dart` conventions.

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../model/instant_service_model.dart';

class InstantServiceRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  InstantServiceRepository({Dio? dio, NetworkInfo? networkInfo})
      : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<void> _requireConnection() async {
    if (!await _networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
  }

  /// Creates an instant service. `client` is set server-side from the JWT —
  /// do not send it. Status starts as `bidding_open` immediately (no fee due
  /// yet).
  Future<InstantServiceModel> createInstantService({
    required String title,
    String? image,
    required String details,
    String? category,
    required int priceMin,
    required int priceMax,
    required InstantServiceLocationModel location,
    InstantServiceScheduleModel? schedule,
  }) async {
    await _requireConnection();

    final response = await _dio.post(
      ApiEndpoints.instantService,
      data: {
        "title": title,
        if (image != null && image.trim().isNotEmpty) "image": image,
        "details": details,
        if (category != null && category.trim().isNotEmpty)
          "category": category,
        "priceMin": priceMin,
        "priceMax": priceMax,
        "location": location.toJson(),
        if (schedule != null && !schedule.isEmpty) "schedule": schedule.toJson(),
      },
    );

    final payload = Map<String, dynamic>.from(response.data);
    if (payload['success'] != true) {
      throw Exception(payload['message'] ?? 'Failed to create instant service');
    }

    return InstantServiceModel.fromJson(
      Map<String, dynamic>.from(payload['data']),
    );
  }

  Future<List<InstantServiceModel>> getMyInstantServices() async {
    await _requireConnection();

    final response = await _dio.get(ApiEndpoints.myInstantServices);
    final payload = Map<String, dynamic>.from(response.data);

    final List list = payload['data'] ?? [];
    return list
        .map((e) => InstantServiceModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<InstantServiceModel>> getAvailableInstantServices() async {
    await _requireConnection();

    final response = await _dio.get(ApiEndpoints.availableInstantServices);
    final payload = Map<String, dynamic>.from(response.data);

    final List list = payload['data'] ?? [];
    return list
        .map((e) => InstantServiceModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<InstantServiceDetailsModel> getInstantService(String id) async {
    await _requireConnection();

    final response = await _dio.get(ApiEndpoints.instantServiceById(id));
    final payload = Map<String, dynamic>.from(response.data);

    if (payload['data'] is! Map) {
      throw Exception('Invalid instant service response');
    }

    return InstantServiceDetailsModel.fromJson(
      Map<String, dynamic>.from(payload['data']),
    );
  }

  Future<InstantServiceBidModel> placeBid({
    required String instantServiceId,
    required int price,
    String? message,
    String? estimatedArrival,
  }) async {
    await _requireConnection();

    final response = await _dio.post(
      ApiEndpoints.instantServiceBid_(instantServiceId),
      data: {
        "price": price,
        if (message != null && message.trim().isNotEmpty) "message": message,
        if (estimatedArrival != null && estimatedArrival.trim().isNotEmpty)
          "estimatedArrival": estimatedArrival,
      },
    );

    final payload = Map<String, dynamic>.from(response.data);
    if (payload['success'] != true) {
      throw Exception(payload['message'] ?? 'Failed to place bid');
    }

    return InstantServiceBidModel.fromJson(
      Map<String, dynamic>.from(payload['data']),
    );
  }

  Future<InstantServiceBidModel> updateBid({
    required String instantServiceId,
    required String bidId,
    int? price,
    String? message,
    String? estimatedArrival,
  }) async {
    await _requireConnection();

    final response = await _dio.put(
      ApiEndpoints.instantServiceUpdateBid(instantServiceId, bidId),
      data: {
        if (price != null) "price": price,
        if (message != null) "message": message,
        if (estimatedArrival != null) "estimatedArrival": estimatedArrival,
      },
    );

    final payload = Map<String, dynamic>.from(response.data);
    if (payload['success'] != true) {
      throw Exception(payload['message'] ?? 'Failed to update bid');
    }

    return InstantServiceBidModel.fromJson(
      Map<String, dynamic>.from(payload['data']),
    );
  }

  Future<List<InstantServiceBidModel>> getBids(String instantServiceId) async {
    await _requireConnection();

    final response = await _dio.get(ApiEndpoints.instantServiceBids(instantServiceId));
    final payload = Map<String, dynamic>.from(response.data);

    final List list = payload['data'] ?? [];
    return list
        .map((e) => InstantServiceBidModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Customer picks a winning bid. Requires status `bidding_open`.
  /// Transitions to `bid_selected`.
  Future<void> selectBid({
    required String instantServiceId,
    required String bidId,
  }) async {
    await _requireConnection();

    await _dio.post(
      ApiEndpoints.instantServiceSelectBid(instantServiceId),
      data: {"bidId": bidId},
    );
  }

  /// Pays the platform fee once a bid has been selected. Backend only
  /// accepts this while status is `bid_selected`. `transactionId` is
  /// required and must be non-empty.
  Future<void> confirmPayment({
    required String instantServiceId,
    String? paymentMethod,
    required String transactionId,
  }) async {
    await _requireConnection();

    await _dio.post(
      ApiEndpoints.instantServicePayment(instantServiceId),
      data: {
        if (paymentMethod != null && paymentMethod.trim().isNotEmpty)
          "paymentMethod": paymentMethod,
        "transactionId": transactionId,
      },
    );
  }

  /// The selected technician locks the job. Requires status `bid_selected`
  /// AND `paymentStatus == 'paid'` server-side.
  Future<void> acceptInstantService(String instantServiceId) async {
    await _requireConnection();

    await _dio.post(ApiEndpoints.instantServiceAccept(instantServiceId));
  }

  Future<void> completeInstantService(String instantServiceId) async {
    await _requireConnection();

    await _dio.post(ApiEndpoints.instantServiceComplete(instantServiceId));
  }

  Future<void> cancelInstantService(
    String instantServiceId, {
    String reason = '',
  }) async {
    await _requireConnection();

    await _dio.post(
      ApiEndpoints.instantServiceCancel(instantServiceId),
      data: {if (reason.trim().isNotEmpty) "reason": reason},
    );
  }
}
