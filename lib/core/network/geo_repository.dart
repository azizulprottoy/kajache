import 'package:dio/dio.dart';

import 'api_client.dart';
import 'api_endpoints.dart';
import 'network_info.dart';

class GeoModel {
  final String id;
  final String name;
  final String nameBn;

  GeoModel({required this.id, required this.name, required this.nameBn});

  factory GeoModel.fromJson(Map<String, dynamic> json) => GeoModel(
        id: json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        nameBn: json['nameBn']?.toString() ?? '',
      );

  String localizedName(bool isBengali) =>
      isBengali && nameBn.isNotEmpty ? nameBn : name;
}

class GeoRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  GeoRepository({Dio? dio, NetworkInfo? networkInfo})
      : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<List<GeoModel>> getDistricts() async {
    if (!await _networkInfo.isConnected) return [];
    final res = await _dio.get(ApiEndpoints.districts);
    final list = res.data is Map ? (res.data['data'] ?? []) : res.data;
    if (list is List) return list.map((e) => GeoModel.fromJson(Map<String, dynamic>.from(e))).toList();
    return [];
  }

  Future<List<GeoModel>> getAreas(String districtId) async {
    if (!await _networkInfo.isConnected) return [];
    final res = await _dio.get(ApiEndpoints.areasByDistrict(districtId));
    final list = res.data is Map ? (res.data['data'] ?? []) : res.data;
    if (list is List) return list.map((e) => GeoModel.fromJson(Map<String, dynamic>.from(e))).toList();
    return [];
  }
}
