import 'package:intl/intl.dart';

final NumberFormat _takaFormat = NumberFormat.decimalPattern('en_US');

/// Taka amount with thousands separators, e.g. `৳12,500`.
String formatTaka(num amount) => '৳${_takaFormat.format(amount)}';
