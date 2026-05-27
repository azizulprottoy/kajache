class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // Users
  static const String users = '/users';
  static String userById(String id) => '/users/$id';

  // Profile
  static const String profileMe = '/profile/me';

  // Upload
  static const String upload = '/upload';

  // Banner
  static const String banner = '/banner';

  // Category
  static const String categories = '/category';
  static const String category = '/category';
  static String categoryById(String id) => '/category/$id';

  // Service
  static const String services = '/service';
  static const String service = '/service';
  static String serviceByslug(String slug) => '/service/$slug';

  // Booking
  static const String bookings = '/booking';
  static const String booking = '/booking';
  static const String myBookings = '/booking/me';
  static const String availableBookings = '/booking/available';
  static String bookingById(String id) => '/booking/$id';

  // Bids
  static String bookingBids(String bookingId) => '/booking/$bookingId/bids';
  static String placeBid(String bookingId) => '/booking/$bookingId/bid';
  static String updateBid(String bookingId, String bidId) =>
      '/booking/$bookingId/bid/$bidId';

  // Bid Chat / Messages
  static String bidMessages(String bidId) => '/booking/bid/$bidId/messages';
  static String sendBidMessage(String bidId) => '/booking/bid/$bidId/message';

  // Payment
  static  String payment(String bookingId) => '/booking/$bookingId/confirm-payment';

  // Coupon
  static const String coupons = '/coupon';
  static const String coupon = '/coupon';

  // Review
  static const String reviews = '/review';
  static const String review = '/review';

  // Comment
  static const String comments = '/comment';
  static const String comment = '/comment';

  // Favorite
  static const String favorites = '/favorite';
  static const String favorite = '/favorite';

  // Notification
  static const String notifications = '/notification';
  static const String notification = '/notification';

  // Chat
  static const String chatMessages = '/chatmessage';
  static const String chatMessage = '/chatmessage';

  // Service Image
  static const String serviceImages = '/serviceimage';
  static const String serviceImage = '/serviceimage';

  // Role
  static const String roles = '/role';
  static const String role = '/role';

  // Permission
  static const String permissions = '/permissions';

  // Employer / Employee Details
  static const String employerDetail = '/employerDetail';
  static const String employeeDetail = '/employeeDetail';

  // Order Coupon
  static const String orderCoupons = '/orderCoupon';
  static const String orderCoupon = '/orderCoupon';
}