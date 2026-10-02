import 'dart:io';

class AppConstants {
  AppConstants._();

  // ── API ─────────────────────────────────────────────────────────────────────
  // static String get baseUrl => Platform.isAndroid
  //     ? 'http://10.0.2.2:3000/api/v1'
  //     : 'http://localhost:3000/api/v1';
  static const String baseUrl = 'https://kpi.kajache.com/api/v1';

  // ── Web pages ───────────────────────────────────────────────────────────────
  static const String termsUrl   = 'https://kajache.com/terms';
  static const String privacyUrl = 'https://kajache.com/privacy';

  // ── User Roles ──────────────────────────────────────────────────────────────
  static const String roleCustomer = 'customer';
  static const String roleWorker   = 'worker';

  // ── Order Status ────────────────────────────────────────────────────────────
  static const String orderPending    = 'pending';
  static const String orderAccepted   = 'accepted';
  static const String orderOnTheWay   = 'on_the_way';
  static const String orderInProgress = 'in_progress';
  static const String orderCompleted  = 'completed';
  static const String orderCancelled  = 'cancelled';

  // ── Payment Methods ─────────────────────────────────────────────────────────
  static const String paymentCash     = 'cash';
  static const String paymentBkash    = 'bkash';
  static const String paymentNagad    = 'nagad';
  static const String paymentCard     = 'card';

  // ── Pagination ──────────────────────────────────────────────────────────────
  static const int defaultPageSize = 10;

  // ── Storage Keys ────────────────────────────────────────────────────────────
  static const String cachePrefix = 'kajache_cache_';
}