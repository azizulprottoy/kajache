import '../../../core/utils/media_url_helper.dart';

class RewordModel {
  final String id;
  final int order;
  final String name;
  final String nameBn;
  final String reword;
  final String rewordBn;
  final int minpoint;
  final String image;
  final String applicablefor;

  const RewordModel({
    required this.id,
    required this.order,
    required this.name,
    required this.nameBn,
    required this.reword,
    required this.rewordBn,
    required this.minpoint,
    required this.image,
    required this.applicablefor,
  });

  factory RewordModel.fromJson(Map<String, dynamic> json) {
    return RewordModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      nameBn: (json['nameBn'] ?? '').toString(),
      reword: (json['reword'] ?? '').toString(),
      rewordBn: (json['rewordBn'] ?? '').toString(),
      minpoint: (json['minpoint'] as num?)?.toInt() ?? 0,
      image: (json['image'] ?? '').toString(),
      applicablefor: (json['applicablefor'] ?? '').toString(),
    );
  }

  String get imageUrl => MediaUrlHelper.resolve(image);

  /// Reward title, localized: falls back to the English value when the
  /// Bangla one is empty.
  String title(bool isBengali) =>
      isBengali && nameBn.isNotEmpty ? nameBn : name;

  /// Reward description, localized the same way as [title].
  String description(bool isBengali) =>
      isBengali && rewordBn.isNotEmpty ? rewordBn : reword;
}
