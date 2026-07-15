import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Resolved display info for a booking status.
class BookingStatusInfo {
  final String label;
  final Color color;

  const BookingStatusInfo({
    required this.label,
    required this.color,
  });
}

class BookingStatusHelper {
  BookingStatusHelper._();

  // Adjust 'bn' if your app uses a different language code for Bangla.
  static bool get _isBangla => Get.locale?.languageCode == 'bn';

  static BookingStatusInfo of(String? status) {
    switch (status) {
      case 'pending_payment':
        return BookingStatusInfo(
          label: _isBangla ? 'পেমেন্ট বাকি' : 'Pending Payment',
          color: const Color(0xFFF59E0B), // amber
        );
      case 'bidding_open':
        return BookingStatusInfo(
          label: _isBangla ? 'বিড চলছে' : 'Bidding Open',
          color: const Color(0xFF3B82F6), // blue
        );
      case 'bid_selected':
        return BookingStatusInfo(
          label: _isBangla ? 'প্রোভাইডার নির্বাচিত' : 'Provider Selected',
          color: const Color(0xFF8B5CF6), // violet
        );
      case 'in_progress':
        return BookingStatusInfo(
          label: _isBangla ? 'কাজ চলছে' : 'In Progress',
          color: const Color(0xFF0EA5E9), // sky
        );
      case 'completed':
        return BookingStatusInfo(
          label: _isBangla ? 'সম্পন্ন' : 'Completed',
          color: const Color(0xFF10B981), // green
        );
      case 'cancelled':
        return BookingStatusInfo(
          label: _isBangla ? 'বাতিল' : 'Cancelled',
          color: const Color(0xFFEF4444), // red
        );
      default:
        return BookingStatusInfo(
          label: _isBangla ? 'অজানা' : 'Unknown',
          color: const Color(0xFF6B7280), // gray
        );
    }
  }
}