import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../model/chat_model.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  Future<List<BookingChatMessageModel>> getMessages(String bidId) async {
    final response = await _dio.get(ApiEndpoints.bidMessages(bidId));
    final data = response.data;
    final list = data is Map ? (data['data'] ?? []) : data;

    if (list is List) {
      return list
          .map((e) => BookingChatMessageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<BookingChatMessageModel> sendMessage(String bidId, String content) async {
    final response = await _dio.post(
      ApiEndpoints.sendBidMessage(bidId),
      data: {'content': content},
    );
    final data = response.data;
    final msgData = data is Map ? (data['data'] ?? data) : data;
    return BookingChatMessageModel.fromJson(Map<String, dynamic>.from(msgData));
  }
}
