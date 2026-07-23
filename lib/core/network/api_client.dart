import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import '../storage/secure_storage_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_services.dart';

class ApiClient {
  ApiClient._();

  static Dio get instance {
    if (_dio != null) return _dio!;
    _dio = _createDio();
    return _dio!;
  }

  static Dio? _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(),
      _ErrorInterceptor(),
      _PrettyLogInterceptor(),
    ]);

    return dio;
  }

  static void resetInstance() => _dio = null;
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final storage = Get.find<SecureStorageService>();
    final token = await storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired — log out
      AppServices.handleUnauthorized();
    }
    handler.next(err);
  }
}

// ── Pretty Log Interceptor ────────────────────────────────────────────────────
class _PrettyLogInterceptor extends Interceptor {
  static const _line = '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

  void _print(String msg) => debugPrint(msg);

  String _prettyJson(dynamic data) {
    if (data == null) return 'null';
    try {
      const encoder = JsonEncoder.withIndent('  ');
      if (data is String) {
        final decoded = jsonDecode(data);
        return encoder.convert(decoded);
      }
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _print('');
    _print('┌$_line');
    _print('│ >> REQUEST');
    _print('│ ${options.method}  ${options.uri}');
    if (options.headers.isNotEmpty) {
      _print('│ Headers:');
      options.headers.forEach((k, v) {
        final val = k == 'Authorization' ? '${(v as String).substring(0, 20)}...' : v;
        _print('│   $k: $val');
      });
    }
    if (options.data != null) {
      _print('│ Body:');
      _prettyJson(options.data)
          .split('\n')
          .forEach((l) => _print('│   $l'));
    }
    _print('└$_line');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final status = response.statusCode ?? 0;
    final ok = status >= 200 && status < 300;
    _print('');
    _print('┌$_line');
    _print('│ ${ok ? "<< RESPONSE OK" : "<< RESPONSE FAIL"}  [$status]');
    _print('│ ${response.requestOptions.method}  ${response.requestOptions.uri}');
    _print('│ Body:');
    _prettyJson(response.data)
        .split('\n')
        .forEach((l) => _print('│   $l'));
    _print('└$_line');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _print('');
    _print('┌$_line');
    _print('│ !! ERROR  [${err.response?.statusCode ?? err.type.name}]');
    _print('│ ${err.requestOptions.method}  ${err.requestOptions.uri}');
    if (err.response?.data != null) {
      _print('│ Body:');
      _prettyJson(err.response!.data)
          .split('\n')
          .forEach((l) => _print('│   $l'));
    } else {
      _print('│ ${err.message}');
    }
    _print('└$_line');
    handler.next(err);
  }
}

// ── Error Interceptor — maps HTTP errors to user-facing messages ──────────────
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        message = 'Connection timed out. Please try again.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection.';
        break;
      default:
        message = err.response?.data?['message'] ?? 'Something went wrong.';
    }
    AppServices.showError(message);
    handler.next(err);
  }
}