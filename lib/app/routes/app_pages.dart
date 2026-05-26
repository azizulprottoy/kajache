import 'package:get/get.dart';
import 'package:kaj_ache/features/auth/views/forgot_password.dart';
import 'package:kaj_ache/features/auth/views/otp_page.dart';
import 'package:kaj_ache/features/chat/binding/chat_binding.dart';
import 'package:kaj_ache/features/chat/view/chat_page.dart';
import 'package:kaj_ache/features/csupport/binding/csupport_binding.dart';
import 'package:kaj_ache/features/csupport/view/csupport_page.dart';
import 'package:kaj_ache/features/home/bindings/shome_binding.dart';
import 'package:kaj_ache/features/home/views/shome_page.dart';
import 'package:kaj_ache/features/privacy/binding/privacy_binding.dart';
import 'package:kaj_ache/features/privacy/view/privacy_page.dart';
import 'package:kaj_ache/features/rewords/bindings/reword_binding.dart';
import 'package:kaj_ache/features/rewords/views/reword_page.dart';
import 'package:kaj_ache/features/services/bindings/service_details_binding.dart';
import 'package:kaj_ache/features/services/views/all_services_list.dart';
import 'package:kaj_ache/features/services/views/service_detail_page.dart';
import 'package:kaj_ache/features/spash/binding/splash_binding.dart';
import 'package:kaj_ache/features/statistics/binding/statistics_binding.dart';
import 'package:kaj_ache/features/statistics/view/statistics_page.dart';
import 'package:kaj_ache/features/terms/binding/terms_binding.dart';
import 'package:kaj_ache/features/terms/view/terms_page.dart';

import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/register_page.dart';
import '../../features/booking/binding/booking_binding.dart';
import '../../features/booking/view/booking_page.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_page.dart';
import '../../features/main/binding/main_binding.dart';
import '../../features/main/view/main_page.dart';
import '../../features/menu/views/menu_page.dart';
import '../../features/orders/bindings/order_binding.dart';
import '../../features/orders/views/orders_page.dart';
import '../../features/portfolio/binding/portfolio_binding.dart';
import '../../features/portfolio/view/portfolio_page.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/views/complete_profile_page.dart';
import '../../features/profile/views/edit_profile_page.dart';
import '../../features/profile/views/profile_page.dart';
import '../../features/services/bindings/service_binding.dart';
import '../../features/spash/view/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: AppRoutes.main,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => ForgotPassword(),
    ),

    GetPage(
      name: AppRoutes.otpPage,
      page: () => OtpPage(),
    ),
    GetPage(
      name: AppRoutes.bookingPage,
      page: () => const BookingPage(),
      binding: BookingBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.services,
    //   page: () =>  AllServices(),
    //   binding: ServiceBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.serviceDetails,
    //   page: () =>  ServiceDetailPage(),
    //   binding: ServiceDetailsBinding(),
    // ),
    GetPage(
      name: AppRoutes.myProfile,
      page: () => const MyProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.completeProfile,
      page: () => const CompleteProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfilePage(),
      binding: ProfileBinding(),
    ),    GetPage(
      name: AppRoutes.homePage,
      page: () => const HomePage(),
      binding: HomeBinding(),

    ),
    GetPage(
      name: AppRoutes.menuPage,
      page: () =>  MenuPage(),

    ),

    // GetPage(
    //   name: AppRoutes.services,
    //   page: () =>  AllServices(),
    //   binding: ServiceBinding(),
    // ),
    GetPage(
      name: AppRoutes.rewordPage,
      page: () =>  RewardsPage(),
      binding: RewardsBinding(),

    ),
    GetPage(
      name: AppRoutes.previousOrders,
      page: () =>  PreviousOrdersPage(),
      binding: PreviousOrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.statisticsPage,
      page: () =>  StatisticsPage(),
      binding: StatisticsBinding(),
    ),
    GetPage(
      name: AppRoutes.shomePage,
      page: () =>  SHomePage(),
      binding: SHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.portfolioPage,
      page: () => const PortfolioPage(),
      binding: PortfolioBinding(),
    ),
    GetPage(
      name: AppRoutes.termsConditionPage,
      page: () => const TermsConditionPage(),
      binding: TermsConditionBinding(),
    ),
    GetPage(
      name: AppRoutes.chatPage,
      page: () => const ChatPage(),
      binding: ChatBinding()
    ),
    GetPage(
      name: AppRoutes.privacyPolicyPage,
      page: () => const PrivacyPolicyPage(),
      binding: PrivacyPolicyBinding(),
    ),
    GetPage(
      name: AppRoutes.customerSupportPage,
      page: () => const CustomerSupportPage(),
      binding: CustomerSupportBinding(),
    ),
  ];
}
