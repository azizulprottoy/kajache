import 'package:get/get.dart';
import 'package:kaj_ache/features/auth/views/forgot_password.dart';
import 'package:kaj_ache/features/auth/views/otp_page.dart';
import 'package:kaj_ache/features/home/bindings/shome_binding.dart';
import 'package:kaj_ache/features/home/views/shome_page.dart';
import 'package:kaj_ache/features/rewords/bindings/reword_binding.dart';
import 'package:kaj_ache/features/rewords/views/reword_page.dart';
import 'package:kaj_ache/features/services/bindings/service_details_binding.dart';
import 'package:kaj_ache/features/services/views/all_services_list.dart';
import 'package:kaj_ache/features/services/views/service_detail_page.dart';
import 'package:kaj_ache/features/spash/binding/splash_binding.dart';
import 'package:kaj_ache/features/statistics/binding/statistics_binding.dart';
import 'package:kaj_ache/features/statistics/view/statistics_page.dart';

import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/register_page.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_page.dart';
import '../../features/main/binding/main_binding.dart';
import '../../features/main/view/main_page.dart';
import '../../features/menu/views/menu_page.dart';
import '../../features/orders/bindings/order_binding.dart';
import '../../features/orders/views/orders_page.dart';
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
    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPassword(),),

    GetPage(name: AppRoutes.otpPage, page: () => OtpPage(),),

    GetPage(
      name: AppRoutes.services,
      page: () =>  AllServices(),
      binding: ServiceBinding(),
    ),
    GetPage(
      name: AppRoutes.serviceDetails,
      page: () =>  ServiceDetailPage(),
      binding: ServiceDetailsBinding(),
    ),
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

    GetPage(
      name: AppRoutes.services,
      page: () =>  AllServices(),
      binding: ServiceBinding(),
    ),
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
  ];
}
