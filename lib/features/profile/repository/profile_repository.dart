import 'dart:io';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  ProfileRepository({Dio? dio, NetworkInfo? networkInfo})
      : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<ProfileModel> getMyProfile() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) throw Exception('No internet connection.');
    final response = await _dio.get(ApiEndpoints.profileMe);
    final body = Map<String, dynamic>.from(response.data);
    final data = body['data'] ?? body;
    return ProfileModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<String>> getCategoryNames() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) throw Exception('No internet connection.');

    final response = await _dio.get(ApiEndpoints.categories);
    final body = Map<String, dynamic>.from(response.data);
    final data = body['data'];

    if (data is! List) return <String>[];

    return data
        .whereType<Map>()
        .map((item) => item['name']?.toString().trim() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<Map<String, dynamic>> updateProfile({
    required Map<String, dynamic> fields,
    File? avatar,
    String avatarFieldName = 'avatar',
  }) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) throw Exception('No internet connection.');

    final formMap = <String, dynamic>{...fields};

    if (avatar != null) {
      formMap[avatarFieldName] = await MultipartFile.fromFile(
        avatar.path,
        filename: avatar.path.split('/').last,
      );
    }

    final response = await _dio.put(
      ApiEndpoints.profileUpdate,
      data: FormData.fromMap(formMap),
      options: Options(contentType: 'multipart/form-data'),
    );

    return Map<String, dynamic>.from(response.data);
  }
}
