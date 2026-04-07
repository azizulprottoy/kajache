import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';

class AuthController extends GetxController {
  final _secureStorage = Get.find<SecureStorageService>();
  final _localStorage  = Get.find<LocalStorageService>();

  RxBool isLoading = false.obs;

  // Called from SplashPage after animation completes
  Future<void> checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2));

    final isFirstTime = !_localStorage.isOnboardingDone;
    if (isFirstTime) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    final token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}