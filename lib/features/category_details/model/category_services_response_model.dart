// To parse this JSON data, do
//
//     final categoryServiceReponseModel = categoryServiceReponseModelFromJson(jsonString);

import 'dart:convert';

import '../../../core/utils/localized_text.dart';
import '../../../core/utils/media_url_helper.dart';

CategoryServiceReponseModel categoryServiceReponseModelFromJson(String str) => CategoryServiceReponseModel.fromJson(json.decode(str));

String categoryServiceReponseModelToJson(CategoryServiceReponseModel data) => json.encode(data.toJson());

class CategoryServiceReponseModel {
  bool? success;
  int? count;
  List<Datum>? data;

  CategoryServiceReponseModel({
    this.success,
    this.count,
    this.data,
  });

  factory CategoryServiceReponseModel.fromJson(Map<String, dynamic> json) => CategoryServiceReponseModel(
    success: json["success"],
    count: json["count"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "count": count,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? title;
  String? titleBn;
  String? slug;
  String? description;
  String? descriptionBn;
  Category? category;
  String? imageLink;
  List<dynamic>? features;
  int? basePrice;
  int? bookingFee;
  String? status;
  CreatedBy? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Datum({
    this.id,
    this.title,
    this.titleBn,
    this.slug,
    this.description,
    this.descriptionBn,
    this.category,
    this.imageLink,
    this.features,
    this.basePrice,
    this.bookingFee,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  /// Service title in the active locale (Bangla when set, else English).
  String get localizedTitle => LocalizedText.pick(title ?? '', titleBn);

  /// Service description in the active locale.
  String get localizedDescription =>
      LocalizedText.pick(description ?? '', descriptionBn);

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    title: json["title"],
    titleBn: json["titleBn"],
    slug: json["slug"],
    description: json["description"],
    descriptionBn: json["descriptionBn"],
    category: json["category"] == null ? null : Category.fromJson(json["category"]),
    imageLink: MediaUrlHelper.resolve((json["image"] ?? json["imageLink"])?.toString()),
    features: json["features"] == null ? [] : List<dynamic>.from(json["features"]!.map((x) => x)),
    basePrice: json["basePrice"],
    bookingFee: json["bookingFee"],
    status: json["status"],
    createdBy: json["createdBy"] == null ? null : CreatedBy.fromJson(json["createdBy"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "titleBn": titleBn,
    "slug": slug,
    "description": description,
    "descriptionBn": descriptionBn,
    "category": category?.toJson(),
    "image": imageLink,
    "features": features == null ? [] : List<dynamic>.from(features!.map((x) => x)),
    "basePrice": basePrice,
    "bookingFee": bookingFee,
    "status": status,
    "createdBy": createdBy?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Category {
  String? id;
  String? name;
  String? slug;

  Category({
    this.id,
    this.name,
    this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["_id"],
    name: json["name"],
    slug: json["slug"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "slug": slug,
  };
}

class CreatedBy {
  String? id;
  String? email;
  String? username;

  CreatedBy({
    this.id,
    this.email,
    this.username,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: json["_id"],
    email: json["email"],
    username: json["username"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "username": username,
  };
}
