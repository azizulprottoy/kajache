import 'package:get/get.dart';
import 'package:kaj_ache/features/auth/repository/auth_repository.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);

  }
}