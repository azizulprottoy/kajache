import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaj_ache/features/auth/views/forgot_password.dart';
import 'package:kaj_ache/features/auth/views/otp_page.dart';
import 'package:kaj_ache/features/services/bindings/service_details_binding.dart';
import 'package:kaj_ache/features/services/views/all_services_list.dart';
import 'package:kaj_ache/features/services/views/service_detail_page.dart';

import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/register_page.dart';
import '../../features/auth/views/splash_page.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_page.dart';
import '../../features/main/binding/main_binding.dart';
import '../../features/main/view/main_page.dart';
import '../../features/menu/views/menu_page.dart';
import '../../features/services/bindings/service_binding.dart';
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
      page: () =>  SplashPage(),
      binding: AuthBinding(),
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
