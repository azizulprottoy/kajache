import 'package:get/get.dart';
import 'package:kaj_ache/features/auth/repository/auth_repository.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController(), fenix: true);
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);

  }
}