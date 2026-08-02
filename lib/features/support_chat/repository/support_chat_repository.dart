import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../model/support_chat_model.dart';

class SupportChatRepository {
  final Dio _dio;

  SupportChatRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  Future<List<SupportChatMessageModel>> getThread() async {
    final response = await _dio.get(ApiEndpoints.supportChatMe);
    final data = response.data;
    final list = data is Map ? (data['data'] ?? []) : data;

    if (list is List) {
      return list
          .map((e) => SupportChatMessageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<void> sendMessage(String message) async {
    await _dio.post(ApiEndpoints.supportChatMessage, data: {'message': message});
  }

  Future<void> markRead() async {
    await _dio.post(ApiEndpoints.supportChatRead);
  }
}
