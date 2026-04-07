import 'package:get/get.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/splash_page.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/register_page.dart';
import '../../features/auth/views/otp_page.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_page.dart';
import '../../features/services/bindings/service_binding.dart';
import '../../features/services/views/categories_page.dart';
import '../../features/services/views/service_list_page.dart';
import '../../features/services/views/service_detail_page.dart';
import '../../features/services/views/booking_page.dart';
import '../../features/services/views/booking_confirm_page.dart';
import '../../features/orders/bindings/order_binding.dart';
import '../../features/orders/views/orders_page.dart';
import '../../features/orders/views/order_detail_page.dart';
import '../../features/tracking/bindings/tracking_binding.dart';
import '../../features/tracking/views/tracking_page.dart';
import '../../features/chat/bindings/chat_binding.dart';
import '../../features/chat/views/conversations_page.dart';
import '../../features/chat/views/chat_page.dart';
import '../../features/payments/bindings/payment_binding.dart';
import '../../features/payments/views/payment_page.dart';
import '../../features/payments/views/transaction_history_page.dart';
import '../../features/reviews/bindings/review_binding.dart';
import '../../features/reviews/views/reviews_page.dart';
import '../../features/reviews/views/write_review_page.dart';
import '../../features/notifications/bindings/notification_binding.dart';
import '../../features/notifications/views/notifications_page.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/views/profile_page.dart';
import '../../features/profile/views/edit_profile_page.dart';
import '../../features/profile/views/worker_profile_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    // ── Auth ──────────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: AuthBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.login,
    //   page: () => const LoginPage(),
    //   binding: AuthBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.register,
    //   page: () => const RegisterPage(),
    //   binding: AuthBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.otp,
    //   page: () => const OtpPage(),
    //   binding: AuthBinding(),
    // ),
    //
    // // ── Home ──────────────────────────────────────────────────────────────────
    // GetPage(
    //   name: AppRoutes.home,
    //   page: () => const HomePage(),
    //   binding: HomeBinding(),
    // ),
    //
    // // ── Services ──────────────────────────────────────────────────────────────
    // GetPage(
    //   name: AppRoutes.categories,
    //   page: () => const CategoriesPage(),
    //   binding: ServiceBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.serviceList,
    //   page: () => const ServiceListPage(),
    //   binding: ServiceBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.serviceDetail,
    //   page: () => const ServiceDetailPage(),
    //   binding: ServiceBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.booking,
    //   page: () => const BookingPage(),
    //   binding: ServiceBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.bookingConfirm,
    //   page: () => const BookingConfirmPage(),
    //   binding: ServiceBinding(),
    // ),
    //
    // // ── Orders ────────────────────────────────────────────────────────────────
    // GetPage(
    //   name: AppRoutes.orders,
    //   page: () => const OrdersPage(),
    //   binding: OrderBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.orderDetail,
    //   page: () => const OrderDetailPage(),
    //   binding: OrderBinding(),
    // ),
    //
    // // ── Tracking ──────────────────────────────────────────────────────────────
    // GetPage(
    //   name: AppRoutes.tracking,
    //   page: () => const TrackingPage(),
    //   binding: TrackingBinding(),
    // ),
    //
    // // ── Chat ──────────────────────────────────────────────────────────────────
    // GetPage(
    //   name: AppRoutes.conversations,
    //   page: () => const ConversationsPage(),
    //   binding: ChatBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.chat,
    //   page: () => const ChatPage(),
    //   binding: ChatBinding(),
    // ),
    //
    // // ── Payments ──────────────────────────────────────────────────────────────
    // GetPage(
    //   name: AppRoutes.payment,
    //   page: () => const PaymentPage(),
    //   binding: PaymentBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.transactions,
    //   page: () => const TransactionHistoryPage(),
    //   binding: PaymentBinding(),
    // ),
    //
    // // ── Reviews ───────────────────────────────────────────────────────────────
    // GetPage(
    //   name: AppRoutes.reviews,
    //   page: () => const ReviewsPage(),
    //   binding: ReviewBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.writeReview,
    //   page: () => const WriteReviewPage(),
    //   binding: ReviewBinding(),
    // ),
    //
    // // ── Notifications ─────────────────────────────────────────────────────────
    // GetPage(
    //   name: AppRoutes.notifications,
    //   page: () => const NotificationsPage(),
    //   binding: NotificationBinding(),
    // ),
    //
    // // ── Profile ───────────────────────────────────────────────────────────────
    // GetPage(
    //   name: AppRoutes.profile,
    //   page: () => const ProfilePage(),
    //   binding: ProfileBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.editProfile,
    //   page: () => const EditProfilePage(),
    //   binding: ProfileBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.workerProfile,
    //   page: () => const WorkerProfilePage(),
    //   binding: ProfileBinding(),
    // ),
  ];
}