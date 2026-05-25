import 'package:dio/dio.dart';
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
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
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