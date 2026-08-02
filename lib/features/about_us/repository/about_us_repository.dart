import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../model/social_media_model.dart';

class AboutUsRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  AboutUsRepository({Dio? dio, NetworkInfo? networkInfo})
      : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<List<SocialMediaModel>> getSocialMedias() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) throw Exception('No internet connection.');

    final response = await _dio.get(ApiEndpoints.socialMedia);
    final data = response.data;
    final list = data is Map ? (data['data'] ?? []) : data;

    if (list is List) {
      final items = list
          .map((e) => SocialMediaModel.fromJson(Map<String, dynamic>.from(e)))
          .where((s) => s.url.isNotEmpty)
          .toList();
      items.sort((a, b) => a.order.compareTo(b.order));
      return items;
    }
    return [];
  }
}
