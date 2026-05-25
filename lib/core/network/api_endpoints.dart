class ApiEndpoints {
  ApiEndpoints._();

  static const String register        = '/auth/register';
  static const String login           = '/auth/login';
  static const String sendOtp         = '/auth/send-otp';
  static const String verifyOtp       = '/auth/verify-otp';
  static const String logout          = '/auth/logout';
  static const String refreshToken    = '/auth/refresh';

  static const String banners         = '/home/banners';
  static const String popularServices = '/home/popular-services';

  static const String categories      = '/categories';
  static String servicesByCategory(String categoryId) => '/categories/$categoryId/services';
  static String serviceDetail(String serviceId)       => '/services/$serviceId';

  static const String createBooking   = '/bookings';
  static String bookingDetail(String bookingId) => '/bookings/$bookingId';

  static const String orders          = '/orders';
  static String orderDetail(String orderId) => '/orders/$orderId';
  static String cancelOrder(String orderId) => '/orders/$orderId/cancel';

  static String tracking(String orderId) => '/orders/$orderId/tracking';

  static const String conversations   = '/conversations';
  static String messages(String conversationId) => '/conversations/$conversationId/messages';
  static String sendMessage(String conversationId) => '/conversations/$conversationId/messages';

  static const String paymentMethods  = '/payments/methods';
  static const String initiatePayment = '/payments/initiate';
  static const String transactions    = '/payments/transactions';

  static String reviews(String workerId) => '/workers/$workerId/reviews';
  static const String submitReview      = '/reviews';

  static const String notifications    = '/notifications';
  static String markRead(String notifId) => '/notifications/$notifId/read';
  static const String markAllRead      = '/notifications/read-all';

  static const String myProfile        = '/profile';
  static const String updateProfile    = '/profile';
  static String workerProfile(String workerId) => '/workers/$workerId';
}