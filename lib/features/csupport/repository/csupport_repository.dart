import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../model/csupport_model.dart';

class CsupportRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  CsupportRepository({Dio? dio, NetworkInfo? networkInfo})
      : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<List<FaqModel>> getFaqs() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) throw Exception('No internet connection.');

    final response = await _dio.get(ApiEndpoints.faqs);
    final data = response.data;
    final list = data is Map ? (data['data'] ?? []) : data;

    if (list is List) {
      return list
          .map((e) => FaqModel.fromJson(Map<String, dynamic>.from(e)))
          .where((f) => f.question.isNotEmpty)
          .toList();
    }
    return [];
  }

  Future<SupportTicketModel> submitTicket({
    required String title,
    required String reason,
  }) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) throw Exception('No internet connection.');

    final response = await _dio.post(
      ApiEndpoints.complain,
      data: {'title': title, 'reason': reason},
    );

    final data = response.data;
    final ticketData = data is Map ? (data['data'] ?? data) : data;
    return SupportTicketModel.fromJson(Map<String, dynamic>.from(ticketData));
  }
}
