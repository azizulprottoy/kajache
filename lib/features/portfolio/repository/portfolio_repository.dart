import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../model/portfolio_model.dart';

class PortfolioRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  PortfolioRepository({
    Dio? dio,
    NetworkInfo? networkInfo,
  })  : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<List<PortfolioItem>> getPortfolios() async {
    await _ensureConnected();

    final response = await _dio.get(ApiEndpoints.portfolio);
    final data = _responseData(response.data);

    final List<dynamic> items;
    if (data is List) {
      items = data;
    } else if (data is Map && data['portfolios'] is List) {
      items = List<dynamic>.from(data['portfolios'] as List);
    } else if (data is Map && data['technitianId'] != null) {
      items = <dynamic>[data];
    } else {
      items = const <dynamic>[];
    }

    return items
        .whereType<Map>()
        .map(
          (item) => PortfolioItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<PortfolioItem> createPortfolio({
    required String technitianId,
    required String technitianName,
    required File image,
    required String servicedetails,
  }) async {
    await _ensureConnected();

    final response = await _dio.post(
      ApiEndpoints.portfolio,
      data: await _portfolioFormData(
        technitianId: technitianId,
        technitianName: technitianName,
        servicedetails: servicedetails,
        imageFile: image,
      ),
      options: Options(contentType: 'multipart/form-data'),
    );

    return PortfolioItem.fromJson(_itemData(response.data));
  }

  Future<PortfolioItem> updatePortfolio({
    required PortfolioItem portfolio,
    required String technitianId,
    required String technitianName,
    required String servicedetails,
    File? image,
  }) async {
    await _ensureConnected();

    if (portfolio.id.isEmpty) {
      throw Exception('Portfolio ID is missing.');
    }

    final response = await _dio.put(
      ApiEndpoints.portfolioById(portfolio.id),
      data: await _portfolioFormData(
        technitianId: technitianId,
        technitianName: technitianName,
        servicedetails: servicedetails,
        imageFile: image,
        existingImage: portfolio.image,
      ),
      options: Options(contentType: 'multipart/form-data'),
    );

    return PortfolioItem.fromJson(_itemData(response.data));
  }

  Future<void> deletePortfolio(String id) async {
    await _ensureConnected();

    if (id.isEmpty) {
      throw Exception('Portfolio ID is missing.');
    }

    await _dio.delete(ApiEndpoints.portfolioById(id));
  }

  Future<FormData> _portfolioFormData({
    required String technitianId,
    required String technitianName,
    required String servicedetails,
    File? imageFile,
    String existingImage = '',
  }) async {
    final fields = <String, dynamic>{
      'technitianId': technitianId,
      'technitianName': technitianName,
      'servicedetails': servicedetails,
    };

    if (imageFile != null) {
      fields['image'] = await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split(Platform.pathSeparator).last,
      );
    } else {
      fields['image'] = existingImage;
    }

    return FormData.fromMap(fields);
  }

  dynamic _responseData(dynamic responseBody) {
    if (responseBody is Map) {
      final body = Map<String, dynamic>.from(responseBody);
      return body['data'] ?? body;
    }
    return responseBody;
  }

  Map<String, dynamic> _itemData(dynamic responseBody) {
    final data = _responseData(responseBody);

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['portfolio'] is Map) {
        return Map<String, dynamic>.from(map['portfolio'] as Map);
      }
      return map;
    }

    throw Exception('Invalid portfolio response.');
  }

  Future<void> _ensureConnected() async {
    if (!await _networkInfo.isConnected) {
      throw Exception('No internet connection.');
    }
  }
}
