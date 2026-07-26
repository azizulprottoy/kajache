import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../models/reword_model.dart';

class RewordRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  RewordRepository({Dio? dio, NetworkInfo? networkInfo})
      : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<List<RewordModel>> getRewards() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) throw Exception('No internet connection.');

    final response = await _dio.get(ApiEndpoints.reward);
    final body = Map<String, dynamic>.from(response.data);
    final data = body['data'];

    if (data is! List) return <RewordModel>[];

    return data
        .whereType<Map>()
        .map((item) => RewordModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
