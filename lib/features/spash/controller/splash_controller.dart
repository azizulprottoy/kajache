import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';

class SplashController extends GetxController {
  final _secureStorage = Get.find<SecureStorageService>();
  final _localStorage = Get.find<LocalStorageService>();

  Future<void> checkAuthState() async {
    final isFirstTime = !_localStorage.isOnboardingDone;
    if (isFirstTime) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}