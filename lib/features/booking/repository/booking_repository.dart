/// =============================
/// BOOKING REPOSITORY
/// =============================

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../model/booking_request_model.dart';

class BookingRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  BookingRepository({Dio? dio, NetworkInfo? networkInfo})
    : _dio = dio ?? ApiClient.instance,
      _networkInfo = networkInfo ?? NetworkInfo();

  Future<Map<String, dynamic>> createBooking(
    BookingRequestModel request,
  ) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection');
    }

    final json = request.toJson();
    final response = await _dio.post(
      ApiEndpoints.booking,
      data: request.photos.isEmpty ? json : await _multipart(json, request),
    );

    return Map<String, dynamic>.from(response.data);
  }

  /// Nested fields go as JSON strings; the backend route parses them back.
  Future<FormData> _multipart(
    Map<String, dynamic> json,
    BookingRequestModel request,
  ) async {
    final fields = <String, dynamic>{
      for (final entry in json.entries)
        entry.key: entry.value is Map || entry.value is List
            ? jsonEncode(entry.value)
            : entry.value.toString(),
    };
    final form = FormData.fromMap(fields);
    // Each file under the same "photos" key, as multer's array('photos') expects
    for (final photo in request.photos) {
      form.files.add(MapEntry(
        'photos',
        await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split(Platform.pathSeparator).last,
        ),
      ));
    }
    return form;
  }

  /// Pays the system fee that moves a draft booking to `bidding_open`.
  Future<Map<String, dynamic>> paySystemFee(
    String bookingId, {
    required String paymentMethod,
    String transactionId = '',
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw Exception('No internet connection');
    }

    final response = await _dio.post(
      ApiEndpoints.paySystemFee(bookingId),
      data: {
        'paymentMethod': paymentMethod,
        if (transactionId.isNotEmpty) 'transactionId': transactionId,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }
}
