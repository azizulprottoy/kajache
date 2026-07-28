import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../models/coupon_model.dart';
import '../models/payment_method_model.dart';

class PaymentRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  PaymentRepository({Dio? dio, NetworkInfo? networkInfo})
      : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) throw Exception('No internet connection.');

    final response = await _dio.get(ApiEndpoints.paymentMethods);
    final data = response.data;
    final list = data is Map ? (data['data'] ?? []) : data;

    if (list is List) {
      return list
          .map((e) => PaymentMethodModel.fromJson(Map<String, dynamic>.from(e)))
          .where((m) => m.isActive)
          .toList();
    }
    return [];
  }

  Future<List<CouponModel>> getCoupons() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) throw Exception('No internet connection.');

    final response = await _dio.get(ApiEndpoints.coupons);
    final data = response.data;
    final list = data is Map ? (data['data'] ?? data) : data;

    if (list is List) {
      return list
          .map((e) => CouponModel.fromJson(Map<String, dynamic>.from(e)))
          .where((c) => c.isValid)
          .toList();
    }
    return [];
  }
}
