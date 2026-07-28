class CouponModel {
  final String id;
  final String code;
  final String type; // 'percentage' | 'fixed'
  final double percentage;
  final double amount;
  final int total;
  final int used;
  final DateTime? startDate;
  final DateTime? endDate;

  CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.percentage,
    required this.amount,
    required this.total,
    required this.used,
    this.startDate,
    this.endDate,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['_id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? 'fixed',
      percentage: double.tryParse(json['parcentage']?.toString() ?? '0') ?? 0,
      amount: double.tryParse(json['ammount']?.toString() ?? '0') ?? 0,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      used: int.tryParse(json['used']?.toString() ?? '0') ?? 0,
      startDate: json['startdate'] != null
          ? DateTime.tryParse(json['startdate'].toString())
          : null,
      endDate: json['enddate'] != null
          ? DateTime.tryParse(json['enddate'].toString())
          : null,
    );
  }

  bool get isValid {
    if (total > 0 && used >= total) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  int discountFor(int price) {
    if (type == 'percentage') {
      return (price * percentage / 100).round();
    }
    return amount.round();
  }
}
