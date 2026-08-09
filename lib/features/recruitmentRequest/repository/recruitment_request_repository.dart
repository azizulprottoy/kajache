// =============================
// RECRUITMENT REQUEST REPOSITORY
// =============================
//
// Backend: /api/v1/recruitmentRequest
// Fee is paid UPFRONT to post the job (before bidding opens) — see
// `confirmPayment`, which is called right after `createRecruitmentRequest`
// in the create-flow controller, unlike Booking/InstantService where
// payment happens after a bid is selected.

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_info.dart';
import '../model/recruitment_request_model.dart';

class RecruitmentRequestRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  RecruitmentRequestRepository({Dio? dio, NetworkInfo? networkInfo})
      : _dio = dio ?? ApiClient.instance,
        _networkInfo = networkInfo ?? NetworkInfo();

  Future<void> _requireConnection() async {
    if (!await _networkInfo.isConnected) {
      throw Exception('No internet connection.');
    }
  }

  /// Creates a new recruitment request. Starts as `pending_payment` —
  /// bidding does not open until `confirmPayment` succeeds.
  Future<RecruitmentRequestModel> createRecruitmentRequest({
    required String title,
    String? image,
    String? details,
    String? category,
    required String duration,
    required num salary,
    String? address,
    String? city,
    String? district,
    File? imageFile,
  }) async {
    await _requireConnection();

    final hasLocation = (address != null && address.trim().isNotEmpty) ||
        (city != null && city.trim().isNotEmpty) ||
        (district != null && district.trim().isNotEmpty);

    final locationMap = hasLocation
        ? {
            if (address != null && address.trim().isNotEmpty)
              'address': address.trim(),
            if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
            if (district != null && district.trim().isNotEmpty)
              'district': district.trim(),
          }
        : null;

    final response = await _dio.post(
      ApiEndpoints.recruitmentRequest,
      data: imageFile != null
          ? await _recruitmentRequestFormData(
              title: title,
              details: details,
              category: category,
              duration: duration,
              salary: salary,
              locationMap: locationMap,
              imageFile: imageFile,
            )
          : {
              'title': title.trim(),
              if (image != null && image.trim().isNotEmpty)
                'image': image.trim(),
              if (details != null && details.trim().isNotEmpty)
                'details': details.trim(),
              if (category != null && category.trim().isNotEmpty)
                'category': category.trim(),
              'duration': duration.trim(),
              'salary': salary,
              if (locationMap != null) 'location': locationMap,
            },
      options: imageFile != null
          ? Options(contentType: 'multipart/form-data')
          : null,
    );

    final json = Map<String, dynamic>.from(response.data);

    if (json['data'] is! Map) {
      throw Exception('Invalid recruitment request response');
    }

    return RecruitmentRequestModel.fromJson(
      Map<String, dynamic>.from(json['data']),
    );
  }

  /// Builds a multipart body for `createRecruitmentRequest` when a cover
  /// image is attached. `location` must be sent as a JSON-encoded string
  /// since multipart form fields don't survive as nested objects — the
  /// backend route does `JSON.parse()` on it when it arrives as a string.
  Future<FormData> _recruitmentRequestFormData({
    required String title,
    String? details,
    String? category,
    required String duration,
    required num salary,
    Map<String, dynamic>? locationMap,
    required File imageFile,
  }) async {
    final fields = <String, dynamic>{
      'title': title.trim(),
      if (details != null && details.trim().isNotEmpty)
        'details': details.trim(),
      if (category != null && category.trim().isNotEmpty)
        'category': category.trim(),
      'duration': duration.trim(),
      'salary': salary,
      if (locationMap != null) 'location': jsonEncode(locationMap),
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split(Platform.pathSeparator).last,
      ),
    };

    return FormData.fromMap(fields);
  }

  /// Pays the posting fee. Only allowed while status is `pending_payment`.
  /// On success the backend sets `paymentStatus: 'paid'` and transitions
  /// status to `hiring_open`, which is what opens bidding.
  Future<void> confirmPayment(
    String id, {
    String? paymentMethod,
    required String transactionId,
  }) async {
    await _requireConnection();

    await _dio.post(
      ApiEndpoints.recruitmentRequestPayment(id),
      data: {
        if (paymentMethod != null && paymentMethod.trim().isNotEmpty)
          'paymentMethod': paymentMethod.trim(),
        'transactionId': transactionId.trim(),
      },
    );
  }

  /// The client's own postings.
  Future<List<RecruitmentRequestModel>> getMyRecruitmentRequests() async {
    await _requireConnection();

    final response = await _dio.get(ApiEndpoints.myRecruitmentRequests);
    final json = Map<String, dynamic>.from(response.data);
    final List list = json['data'] ?? [];

    return list
        .whereType<Map>()
        .map((e) => RecruitmentRequestModel.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }

  /// Open postings (`status: hiring_open`) a technician can apply to.
  Future<List<RecruitmentRequestModel>> getAvailableRecruitmentRequests() async {
    await _requireConnection();

    final response = await _dio.get(ApiEndpoints.availableRecruitmentRequests);
    final json = Map<String, dynamic>.from(response.data);
    final List list = json['data'] ?? [];

    return list
        .whereType<Map>()
        .map((e) => RecruitmentRequestModel.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }

  /// Full details for one posting — includes `bids`, `bidsCount`, `hasBid`,
  /// `myBid`.
  Future<RecruitmentRequestDetailsModel> getRecruitmentRequest(String id) async {
    await _requireConnection();

    final response = await _dio.get(ApiEndpoints.recruitmentRequestById(id));
    final json = Map<String, dynamic>.from(response.data);

    if (json['data'] is! Map) {
      throw Exception('Invalid recruitment request response');
    }

    return RecruitmentRequestDetailsModel.fromJson(
      Map<String, dynamic>.from(json['data']),
    );
  }

  /// Technician applies to an open posting.
  Future<RecruitmentBidModel> placeBid(
    String id, {
    required num proposedSalary,
    String? message,
  }) async {
    await _requireConnection();

    final response = await _dio.post(
      ApiEndpoints.recruitmentRequestBid_(id),
      data: {
        'proposedSalary': proposedSalary,
        if (message != null && message.trim().isNotEmpty)
          'message': message.trim(),
      },
    );

    final json = Map<String, dynamic>.from(response.data);

    if (json['data'] is! Map) {
      throw Exception('Invalid application response');
    }

    return RecruitmentBidModel.fromJson(
      Map<String, dynamic>.from(json['data']),
    );
  }

  /// Technician revises their own active application.
  Future<RecruitmentBidModel> updateBid(
    String id,
    String bidId, {
    num? proposedSalary,
    String? message,
  }) async {
    await _requireConnection();

    final response = await _dio.put(
      ApiEndpoints.recruitmentRequestUpdateBid(id, bidId),
      data: {
        if (proposedSalary != null) 'proposedSalary': proposedSalary,
        if (message != null) 'message': message.trim(),
      },
    );

    final json = Map<String, dynamic>.from(response.data);

    if (json['data'] is! Map) {
      throw Exception('Invalid application response');
    }

    return RecruitmentBidModel.fromJson(
      Map<String, dynamic>.from(json['data']),
    );
  }

  /// All applications for a posting (client view).
  Future<List<RecruitmentBidModel>> getBids(String id) async {
    await _requireConnection();

    final response = await _dio.get(ApiEndpoints.recruitmentRequestBids(id));
    final json = Map<String, dynamic>.from(response.data);
    final List list = json['data'] ?? [];

    return list
        .whereType<Map>()
        .map((e) => RecruitmentBidModel.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }

  /// Client picks an applicant ("hires" them). Transitions to `hired`.
  Future<void> selectBid(String id, String bidId) async {
    await _requireConnection();

    await _dio.post(
      ApiEndpoints.recruitmentRequestSelectBid(id),
      data: {'bidId': bidId},
    );
  }

  /// Client ends the engagement. Requires status `hired`.
  Future<void> endRecruitmentRequest(String id) async {
    await _requireConnection();

    await _dio.post(ApiEndpoints.recruitmentRequestEnd(id));
  }

  /// Client cancels. Not allowed once `ended`/`cancelled`.
  Future<void> cancelRecruitmentRequest(String id, {String? reason}) async {
    await _requireConnection();

    await _dio.post(
      ApiEndpoints.recruitmentRequestCancel(id),
      data: {
        if (reason != null && reason.trim().isNotEmpty)
          'reason': reason.trim(),
      },
    );
  }
}
