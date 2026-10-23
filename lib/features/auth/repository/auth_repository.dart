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

  // The API answers the same for unknown emails, so this only fails on
  // network/validation/rate-limit errors (thrown as DioException).
  Future<void> forgotPassword(String email) async {
    await _ensureConnected();
    await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  Future<void> verifyResetCode(String email, String code) async {
    await _ensureConnected();
    await _dio.post(
      ApiEndpoints.verifyResetCode,
      data: {'email': email, 'code': code},
    );
  }

  Future<void> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    await _ensureConnected();
    await _dio.post(
      ApiEndpoints.resetPassword,
      data: {'email': email, 'code': code, 'newPassword': newPassword},
    );
  }

  Future<void> _ensureConnected() async {
    if (!await _networkInfo.isConnected) {
      throw Exception('No internet connection.');
    }
  }
}