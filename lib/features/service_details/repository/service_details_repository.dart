import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../../home/models/services_response_model.dart';
import '../../home/models/available_booking_response_model.dart';
import '../../reviews/models/review_model.dart';
import '../model/comment_model.dart';
import '../model/service_details_response_model.dart';

class ServiceDetailsRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  ServiceDetailsRepository({Dio? dio, NetworkInfo? networkInfo})
      : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<ServiceModel?> getServiceBySlug(String slug) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.get(ApiEndpoints.serviceByslug(slug));

    final result = ServiceDetailsResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );

    return result.data;
  }

  Future<List<CommentModel>> getCommentsByServiceId(String serviceId) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.get(
      ApiEndpoints.comments,
      queryParameters: {'serviceId': serviceId},
    );

    final payload = Map<String, dynamic>.from(response.data);
    final List listData = payload['data'] as List? ?? [];
    return listData
        .map((item) => CommentModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<ReviewModel>> getReviewsByServiceId(String serviceId) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.get(
      ApiEndpoints.reviews,
      queryParameters: {'serviceId': serviceId},
    );

    final payload = Map<String, dynamic>.from(response.data);
    final List listData = payload['data'] as List? ?? [];
    return listData
        .map((item) => ReviewModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<CommentModel> addComment({
    required String serviceId,
    required String name,
    required String comment,
    String? propic,
  }) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.post(
      ApiEndpoints.comments,
      data: {
        'service': serviceId,
        'name': name,
        'comment': comment,
        if (propic != null && propic.isNotEmpty) 'propic': propic,
      },
    );

    final payload = Map<String, dynamic>.from(response.data);
    return CommentModel.fromJson(
      Map<String, dynamic>.from(payload['data']),
    );
  }

  /// Add a reply to a comment. Returns the full updated comment (with replies).
  Future<CommentModel> replyToComment({
    required String commentId,
    required String reply,
    String? name,
    String? propic,
  }) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.post(
      ApiEndpoints.commentReply(commentId),
      data: {
        'reply': reply,
        if (name != null && name.isNotEmpty) 'name': name,
        if (propic != null && propic.isNotEmpty) 'propic': propic,
      },
    );

    final payload = Map<String, dynamic>.from(response.data);
    return CommentModel.fromJson(
      Map<String, dynamic>.from(payload['data']),
    );
  }

  /// Delete a reply from a comment. Returns the full updated comment.
  Future<CommentModel> deleteReply({
    required String commentId,
    required String replyId,
  }) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.delete(
      ApiEndpoints.commentReplyById(commentId, replyId),
    );

    final payload = Map<String, dynamic>.from(response.data);
    return CommentModel.fromJson(
      Map<String, dynamic>.from(payload['data']),
    );
  }

  Future<ProviderBidModel> placeBid({
    required String bookingId,
    required double price,
    required String estimatedArrival,
    String message = '',
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.post(
      ApiEndpoints.placeBid(bookingId),
      data: {
        'price': price,
        'estimatedArrival': estimatedArrival,
        if (message.isNotEmpty) 'message': message,
      },
    );

    final payload = Map<String, dynamic>.from(response.data);
    return ProviderBidModel.fromJson(
      Map<String, dynamic>.from(payload['data']),
    );
  }

  Future<ProviderBidModel> updateBid({
    required String bookingId,
    required String bidId,
    required double price,
    required String estimatedArrival,
    required String message,
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection.');
    }

    final response = await _dio.put(
      ApiEndpoints.updateBid(bookingId, bidId),
      data: {
        'price': price,
        'estimatedArrival': estimatedArrival,
        'message': message,
      },
    );

    final payload = Map<String, dynamic>.from(response.data);
    return ProviderBidModel.fromJson(
      Map<String, dynamic>.from(payload['data']),
    );
  }
}

