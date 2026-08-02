import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/network_info.dart';

class TechnicianLocationModel {
  final double lat;
  final double lng;
  final DateTime? updatedAt;

  TechnicianLocationModel({required this.lat, required this.lng, this.updatedAt});

  factory TechnicianLocationModel.fromJson(Map<String, dynamic> json) =>
      TechnicianLocationModel(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString())
            : null,
      );
}

class TrackingRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  TrackingRepository({Dio? dio, NetworkInfo? networkInfo})
      : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  /// Technician calls this every 5s to broadcast their position.
  Future<void> updateTechnicianLocation(
      String bookingId, double lat, double lng) async {
    if (!await _networkInfo.isConnected) return;
    try {
      await _dio.put(
        ApiEndpoints.updateTechnicianLocation(bookingId),
        data: {'lat': lat, 'lng': lng},
      );
    } catch (_) {}
  }

  /// Customer calls this every 5s to get technician position.
  Future<TechnicianLocationModel?> getTechnicianLocation(
      String bookingId) async {
    if (!await _networkInfo.isConnected) return null;
    try {
      final res = await _dio.get(ApiEndpoints.getTechnicianLocation(bookingId));
      final data = res.data is Map ? res.data['data'] : null;
      if (data == null) return null;
      return TechnicianLocationModel.fromJson(
          Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }
}
