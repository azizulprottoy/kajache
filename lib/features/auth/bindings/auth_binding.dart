import 'package:get/get.dart';
import 'package:kaj_ache/features/auth/repository/auth_repository.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);

  }
}