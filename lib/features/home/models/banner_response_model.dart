import '../../../core/utils/media_url_helper.dart';

class BannerResponseModel {
  final bool success;
  final int count;
  final List<AppBannerModel> data;

  BannerResponseModel({
    required this.success,
    required this.count,
    required this.data,
  });

  factory BannerResponseModel.fromJson(Map<String, dynamic> json) {
    return BannerResponseModel(
      success: json['success'] == true,
      count: json['count'] ?? 0,
      data: json['data'] is List
          ? (json['data'] as List)
          .map((item) => AppBannerModel.fromJson(
        Map<String, dynamic>.from(item),
      ))
          .toList()
          : [],
    );
  }
}

class AppBannerModel {
  final String id;
  final String title;
  final int order;
  final String webImageLink;
  final String appImageApp;
  final int clicks;
  final String redirect;
  final String createdAt;
  final String updatedAt;

  AppBannerModel({
    required this.id,
    required this.title,
    required this.order,
    required this.webImageLink,
    required this.appImageApp,
    required this.clicks,
    required this.redirect,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppBannerModel.fromJson(Map<String, dynamic> json) {
    return AppBannerModel(
      id: json['_id']?.toString() ?? '',
      title: json['newTitle']?.toString() ?? '',
      order: json['order'] ?? 0,
      webImageLink: MediaUrlHelper.resolve(json['webImageLink']?.toString()),
      appImageApp: MediaUrlHelper.resolve(json['appImageApp']?.toString()),
      clicks: json['clicks'] ?? 0,
      redirect: json['redirect']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  String get imageUrl => appImageApp.isNotEmpty ? appImageApp : webImageLink;
}