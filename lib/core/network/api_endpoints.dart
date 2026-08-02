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
  static const String profileUpdate = '/profile/update';
  // Upload
  static const String upload = '/upload';

  // Portfolio
  static const String portfolio = '/portfolio';
  static String portfolioById(String id) => '/portfolio/$id';

  // Social Media
  static const String socialMedia = '/socialMedia';

  // Banner
  static const String banner = '/banner';
  static const String advertisements = '/advertisement';
  static String adClick(String id) => '/advertisement/$id/click';

  // Category
  static const String categories = '/category';
  static const String category = '/category';
  static String categoryById(String id) => '/category/$id';

  // Service
  static const String services = '/service';
  static const String service = '/service';
  static String serviceByslug(String slug) => '/service/$slug';
  static String serviceBycategory(String categorySlug) =>  '/service/category/$categorySlug';

  // Booking
  static const String bookings = '/booking';
  static const String booking = '/booking';
  static const String myBookings = '/booking/me';
  static const String availableBookings = '/booking/available';
  static const String providerDashboard = '/booking/provider/dashboard';
  static const String providerBids = '/booking/provider/bids';
  static String bookingById(String id) => '/booking/$id';
  static String selectBid(String bookingId) =>
      '/booking/$bookingId/select-bid';
  static String acceptBooking(String bookingId) =>
      '/booking/$bookingId/accept';
  static String completeBooking(String bookingId) =>
      '/booking/$bookingId/complete';

  // Bids
  static String bookingBids(String bookingId) => '/booking/$bookingId/bids';
  static String placeBid(String bookingId) => '/booking/$bookingId/bid';
  static String updateBid(String bookingId, String bidId) =>
      '/booking/$bookingId/bid/$bidId';

  // Bid Chat / Messages
  static String bidMessages(String bidId) => '/booking/bid/$bidId/messages';
  static String sendBidMessage(String bidId) => '/booking/bid/$bidId/message';

  // Payment
  static String payment(String bookingId) => '/booking/$bookingId/confirm-payment';
  static String markCashReceived(String bookingId) => '/booking/$bookingId/mark-cash-received';
  static String updateTechnicianLocation(String bookingId) => '/booking/$bookingId/technician-location';
  static String getTechnicianLocation(String bookingId) => '/booking/$bookingId/technician-location';
  static const String paymentMethods = '/paymentMethod';

  // Coupon
  static const String coupons = '/coupon';
  static const String coupon = '/coupon';

  // Review
  static const String reviews = '/review';
  static const String review = '/review';
  static const String employeeRating = '/employeeRating';

  // Complain / Support
  static const String complain = '/complain';

  // FAQ
  static const String faqs = '/faq';
  static const String districts = '/district';
  static String areasByDistrict(String districtId) => '/area?district=$districtId';

  // Comment
  static const String comments = '/comment';
  static const String comment = '/comment';
  static String commentReply(String commentId) => '/comment/$commentId/reply';
  static String commentReplyById(String commentId, String replyId) =>
      '/comment/$commentId/reply/$replyId';

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

  // Reward
  static const String rewards = '/reward';
  static const String reward = '/reward';
  static String rewardById(String id) => '/reward/$id';

  // Support Chat
  static const String supportChatMessage = '/supportChat/message';
  static const String supportChatMe = '/supportChat/me';
  static const String supportChatRead = '/supportChat/me/read';
}
