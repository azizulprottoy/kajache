class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String register        = '/auth/register';
  static const String login           = '/auth/login';
  static const String sendOtp         = '/auth/send-otp';
  static const String verifyOtp       = '/auth/verify-otp';
  static const String logout          = '/auth/logout';
  static const String refreshToken    = '/auth/refresh';

  // ── Home ────────────────────────────────────────────────────────────────────
  static const String banners         = '/home/banners';
  static const String popularServices = '/home/popular-services';

  // ── Services ────────────────────────────────────────────────────────────────
  static const String categories      = '/categories';
  static String servicesByCategory(String categoryId) => '/categories/$categoryId/services';
  static String serviceDetail(String serviceId)       => '/services/$serviceId';

  // ── Booking ─────────────────────────────────────────────────────────────────
  static const String createBooking   = '/bookings';
  static String bookingDetail(String bookingId) => '/bookings/$bookingId';

  // ── Orders ──────────────────────────────────────────────────────────────────
  static const String orders          = '/orders';
  static String orderDetail(String orderId) => '/orders/$orderId';
  static String cancelOrder(String orderId) => '/orders/$orderId/cancel';

  // ── Tracking ────────────────────────────────────────────────────────────────
  static String tracking(String orderId) => '/orders/$orderId/rewords';

  // ── Chat ────────────────────────────────────────────────────────────────────
  static const String conversations   = '/conversations';
  static String messages(String conversationId) => '/conversations/$conversationId/messages';
  static String sendMessage(String conversationId) => '/conversations/$conversationId/messages';

  // ── Payments ────────────────────────────────────────────────────────────────
  static const String paymentMethods  = '/payments/methods';
  static const String initiatePayment = '/payments/initiate';
  static const String transactions    = '/payments/transactions';

  // ── Reviews ─────────────────────────────────────────────────────────────────
  static String reviews(String workerId) => '/workers/$workerId/reviews';
  static const String submitReview      = '/reviews';

  // ── Notifications ───────────────────────────────────────────────────────────
  static const String notifications    = '/notifications';
  static String markRead(String notifId) => '/notifications/$notifId/read';
  static const String markAllRead      = '/notifications/read-all';

  // ── Profile ─────────────────────────────────────────────────────────────────
  static const String myProfile        = '/profile';
  static const String updateProfile    = '/profile';
  static String workerProfile(String workerId) => '/workers/$workerId';
}