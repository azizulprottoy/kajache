import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaj_ache/features/services/views/all_services_list.dart';

import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/splash_page.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_page.dart';
import '../../features/menu/views/menu_page.dart';
import '../../features/services/bindings/service_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    // ── Auth ──────────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () =>  SplashPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: '/all-services',
      page: () =>  AllServices(),
      binding: ServiceBinding(),

    ),
    GetPage(
      name: '/home',
      page: () => const HomePage(),
      binding: HomeBinding(),

    ),
    GetPage(
      name: '/menu',
      page: () =>  MenuPage(),

    ),

    GetPage(
      name: AppRoutes.services,
      page: () =>  AllServices(),
      binding: ServiceBinding(),
    ),
  ];
}
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

//
// // ── Services ──────────────────────────────────────────────────────────────
// GetPage(
//   name: AppRoutes.categories,
//   page: () => const CategoriesPage(),
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
    //   name: AppRoutes.menu,
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
//   ];
// }