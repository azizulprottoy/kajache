import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../model/advertisement_model.dart';

class AdvertisementRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  AdvertisementRepository({Dio? dio, NetworkInfo? networkInfo})
      : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<List<AdvertisementModel>> getAll() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) return [];

    final response = await _dio.get(ApiEndpoints.advertisements);
    final data = response.data;
    final list = data is Map ? (data['data'] ?? []) : data;

    if (list is List) {
      return list
          .map((e) => AdvertisementModel.fromJson(Map<String, dynamic>.from(e)))
          .where((a) => a.isForApp && a.isActive && a.imageUrl.isNotEmpty)
          .toList();
    }
    return [];
  }

  Future<void> trackClick(String adId) async {
    try {
      await _dio.post(ApiEndpoints.adClick(adId));
    } catch (_) {}
  }
}
