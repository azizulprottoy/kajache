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
      case 'draft':
        return BookingStatusInfo(
          label: _isBangla ? 'খসড়া' : 'Draft',
          color: const Color(0xFF64748B), // slate
        );
      case 'pending_reassignment':
        return BookingStatusInfo(
          label: _isBangla ? 'নতুন টেকনিশিয়ান খোঁজা হচ্ছে' : 'Reassigning',
          color: const Color(0xFFF97316), // orange
        );
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
      // Recruitment request statuses
      case 'hiring_open':
        return BookingStatusInfo(
          label: _isBangla ? 'নিয়োগ চলছে' : 'Hiring Open',
          color: const Color(0xFF3B82F6), // blue
        );
      case 'hired':
        return BookingStatusInfo(
          label: _isBangla ? 'নিয়োগ সম্পন্ন' : 'Hired',
          color: const Color(0xFF10B981), // green
        );
      case 'ended':
        return BookingStatusInfo(
          label: _isBangla ? 'শেষ হয়েছে' : 'Ended',
          color: const Color(0xFF64748B), // slate
        );
      default:
        return BookingStatusInfo(
          label: _isBangla ? 'অজানা' : 'Unknown',
          color: const Color(0xFF6B7280), // gray
        );
    }
  }

  /// Payment status of an instant service / recruitment request.
  static BookingStatusInfo payment(String? status) {
    switch (status) {
      case 'paid':
        return BookingStatusInfo(
          label: _isBangla ? 'পরিশোধিত' : 'Paid',
          color: const Color(0xFF10B981), // green
        );
      case 'refund_pending':
        return BookingStatusInfo(
          label: _isBangla ? 'রিফান্ড প্রক্রিয়াধীন' : 'Refund pending',
          color: const Color(0xFFF59E0B), // amber
        );
      case 'refunded':
        return BookingStatusInfo(
          label: _isBangla ? 'রিফান্ড করা হয়েছে' : 'Refunded',
          color: const Color(0xFF0EA5E9), // sky
        );
      case 'forfeited':
        return BookingStatusInfo(
          label: _isBangla ? 'ফি ফেরতযোগ্য নয়' : 'Fee forfeited',
          color: const Color(0xFFEF4444), // red
        );
      default:
        return BookingStatusInfo(
          label: _isBangla ? 'অপরিশোধিত' : 'Unpaid',
          color: const Color(0xFF64748B), // slate
        );
    }
  }

  /// Status of a technician's bid / application.
  static BookingStatusInfo bid(String? status) {
    switch (status) {
      case 'selected':
        return BookingStatusInfo(
          label: _isBangla ? 'নির্বাচিত' : 'Selected',
          color: const Color(0xFF10B981), // green
        );
      case 'rejected':
        return BookingStatusInfo(
          label: _isBangla ? 'নির্বাচিত হয়নি' : 'Not selected',
          color: const Color(0xFF64748B), // slate
        );
      case 'cancelled':
        return BookingStatusInfo(
          label: _isBangla ? 'বাতিল' : 'Cancelled',
          color: const Color(0xFFEF4444), // red
        );
      default:
        return BookingStatusInfo(
          label: _isBangla ? 'সক্রিয়' : 'Active',
          color: const Color(0xFF3B82F6), // blue
        );
    }
  }
}