import '../../../core/utils/media_url_helper.dart';

class PaymentMethodModel {
  final String id;
  final String name;
  final String nameBn;
  final String account;
  final String image;
  final String status;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.account,
    required this.image,
    required this.status,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameBn: json['nameBn']?.toString() ?? '',
      account: json['account']?.toString() ?? '',
      image: MediaUrlHelper.resolve(json['image']?.toString() ?? ''),
      status: json['status']?.toString() ?? 'active',
    );
  }

  bool get isActive => status == 'active';

  String localizedName(bool isBengali) =>
      isBengali && nameBn.isNotEmpty ? nameBn : name;
}
