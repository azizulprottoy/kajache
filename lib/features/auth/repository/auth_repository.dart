import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';

class AuthRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  AuthRepository({
    Dio? dio,
    NetworkInfo? networkInfo,
  })  : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<RegisterResponseModel> register(
      RegisterRequestModel request,
      ) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    return RegisterResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    return LoginResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}