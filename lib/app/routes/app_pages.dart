import 'package:get/get.dart';
import 'package:kaj_ache/features/about_us/binding/about_us_binding.dart';
import 'package:kaj_ache/features/about_us/view/about_us_page.dart';
import 'package:kaj_ache/features/support_chat/binding/support_chat_binding.dart';
import 'package:kaj_ache/features/support_chat/view/support_chat_page.dart';
import 'package:kaj_ache/features/auth/views/forgot_password.dart';
import 'package:kaj_ache/features/auth/views/otp_page.dart';
import 'package:kaj_ache/features/category_details/binding/category_details_binding.dart';
import 'package:kaj_ache/features/category_details/view/category_details_page.dart';
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
import 'package:kaj_ache/features/spash/binding/splash_binding.dart';
import 'package:kaj_ache/features/statistics/binding/statistics_binding.dart';
import 'package:kaj_ache/features/statistics/view/statistics_page.dart';
import 'package:kaj_ache/features/terms/binding/terms_binding.dart';
import 'package:kaj_ache/features/terms/view/terms_page.dart';

import '../../features/auth/bindings/login_binding.dart';
import '../../features/auth/bindings/register_binding.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/register_page.dart';
import '../../features/booking/binding/booking_binding.dart';
import '../../features/booking/view/booking_page.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_page.dart';
import '../../features/main/binding/main_binding.dart';
import '../../features/main/view/main_page.dart';
import '../../features/menu/views/menu_page.dart';
import '../../features/my_bookings/bindings/MyBookDetailsBinding.dart';
import '../../features/my_bookings/bindings/my_booking_binding.dart';
import '../../features/my_bookings/view/my_booking_details_page.dart';
import '../../features/my_bookings/view/my_bookings_page.dart';
import '../../features/orders/bindings/order_binding.dart';
import '../../features/orders/views/orders_page.dart';
import '../../features/portfolio/binding/portfolio_binding.dart';
import '../../features/portfolio/view/portfolio_page.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/views/complete_profile_page.dart';
import '../../features/profile/views/edit_profile_page.dart';
import '../../features/profile/views/profile_page.dart';
import '../../features/sbooking/booking_details_binding.dart';
import '../../features/sbooking/booking_details_page.dart';
import '../../features/service_details/binding/service_details_binding.dart';
import '../../features/service_details/view/service_details_page.dart';
import '../../features/services/bindings/service_binding.dart';
import '../../features/spash/view/splash_page.dart';
import '../../features/instantService/bindings/instant_service_binding.dart';
import '../../features/instantService/view/instant_service_page.dart';
import '../../features/instantService/bindings/my_instant_services_binding.dart';
import '../../features/instantService/view/my_instant_services_page.dart';
import '../../features/instantService/bindings/my_instant_service_details_binding.dart';
import '../../features/instantService/view/my_instant_service_details_page.dart';
import '../../features/instantService/bindings/available_instant_services_binding.dart';
import '../../features/instantService/view/available_instant_services_page.dart';
import '../../features/recruitmentRequest/bindings/recruitment_request_binding.dart';
import '../../features/recruitmentRequest/view/recruitment_request_page.dart';
import '../../features/recruitmentRequest/bindings/my_recruitment_requests_binding.dart';
import '../../features/recruitmentRequest/view/my_recruitment_requests_page.dart';
import '../../features/recruitmentRequest/bindings/my_recruitment_request_details_binding.dart';
import '../../features/recruitmentRequest/view/my_recruitment_request_details_page.dart';
import '../../features/recruitmentRequest/bindings/available_recruitment_requests_binding.dart';
import '../../features/recruitmentRequest/view/available_recruitment_requests_page.dart';
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
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterPage(),
      binding: RegisterBinding(),
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
    GetPage(
      name: AppRoutes.categoryDetails,
      page: () =>  CategoryDetailsPage(),
      binding: CategoryDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.serviceDetails,
      page: () =>  const ServiceDetailsPage(),
      binding: ServiceDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingDetails,
      page: () => const BookingDetailsPage(),
      binding: BookingDetailsBinding(),
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
      name: AppRoutes.myBookings,
      page: () =>  MyBookingPage(),
      binding: MyBookingBinding(),

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
    GetPage(
      name: AppRoutes.myBookingDetails ,
      page: () => const MyBookingDetailsPage(),
      binding: MyBookingDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.aboutUsPage,
      page: () => const AboutUsPage(),
      binding: AboutUsBinding(),
    ),
    GetPage(
      name: AppRoutes.supportChatPage,
      page: () => const SupportChatPage(),
      binding: SupportChatBinding(),
    ),
    GetPage(
      name: AppRoutes.instantServicePage,
      page: () => const InstantServicePage(),
      binding: InstantServiceBinding(),
    ),
    GetPage(
      name: AppRoutes.myInstantServices,
      page: () => const MyInstantServicesPage(),
      binding: MyInstantServicesBinding(),
    ),
    GetPage(
      name: AppRoutes.myInstantServiceDetails,
      page: () => const MyInstantServiceDetailsPage(),
      binding: MyInstantServiceDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.availableInstantServices,
      page: () => const AvailableInstantServicesPage(),
      binding: AvailableInstantServicesBinding(),
    ),
    GetPage(
      name: AppRoutes.recruitmentRequestPage,
      page: () => const RecruitmentRequestPage(),
      binding: RecruitmentRequestBinding(),
    ),
    GetPage(
      name: AppRoutes.myRecruitmentRequests,
      page: () => const MyRecruitmentRequestsPage(),
      binding: MyRecruitmentRequestsBinding(),
    ),
    GetPage(
      name: AppRoutes.myRecruitmentRequestDetails,
      page: () => const MyRecruitmentRequestDetailsPage(),
      binding: MyRecruitmentRequestDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.availableRecruitmentRequests,
      page: () => const AvailableRecruitmentRequestsPage(),
      binding: AvailableRecruitmentRequestsBinding(),
    ),
  ];
}
