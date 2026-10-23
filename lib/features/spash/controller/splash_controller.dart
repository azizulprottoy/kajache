import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/notifications/push_notification_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../auth/controllers/login_controller.dart';
import '../../auth/controllers/register_controller.dart';

class SplashController extends GetxController {
  final _secureStorage = Get.find<SecureStorageService>();
  final _localStorage = Get.find<LocalStorageService>();

  Future<void> checkAuthState() async {
    var token = await _secureStorage.getToken();
    // Sessions saved before the checkbox existed have no flag; keep them
    if (token != null && _localStorage.read<bool>(rememberMeKey) == false) {
      await _secureStorage.deleteToken();
      token = null;
    }
    if (token != null && token.isNotEmpty) {
      final userType = _localStorage.read<String>('user_type');
      Get.offAllNamed(AppRoutes.main, arguments: userType != null
          ? (userType == 'serviceProvider' ? UserType.serviceProvider : UserType.buyer)
          : UserType.buyer);
      PushNotificationService.to.onSignedIn();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}