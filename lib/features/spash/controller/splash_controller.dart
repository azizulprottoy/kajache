import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../auth/controllers/register_controller.dart';

class SplashController extends GetxController {
  final _secureStorage = Get.find<SecureStorageService>();
  final _localStorage = Get.find<LocalStorageService>();

  Future<void> checkAuthState() async {
    final token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      final userType = _localStorage.read<String>('user_type');
      Get.offAllNamed(AppRoutes.main, arguments: userType != null
          ? (userType == 'serviceProvider' ? UserType.serviceProvider : UserType.buyer)
          : UserType.buyer);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}