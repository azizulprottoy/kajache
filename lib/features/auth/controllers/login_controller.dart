import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaj_ache/features/auth/controllers/register_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../arguments/otp_argument.dart';
import '../models/register_request_model.dart';
import '../repository/auth_repository.dart';



class LoginController extends GetxController {
  final _secureStorage = Get.find<SecureStorageService>();
  final _localStorage = Get.find<LocalStorageService>();
  final _authRepository = Get.find<AuthRepository>();

  final RxBool isLoading = false.obs;

  final formKey = GlobalKey<FormState>();

  final inputController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();

    try {
      isLoading.value = true;

      final request = LoginRequestModel(
        email: inputController.text.trim().toLowerCase(),
        password: passwordController.text,
      );

      final response = await _authRepository.login(request);

      if (!response.success) {
        return;
      }

      await _secureStorage.saveToken(response.token);

      final roleTitle = response.user.role?.title.isNotEmpty == true
          ? response.user.role!.title
          : response.user.roleModelName;

      final userType = _mapRoleToUserType(roleTitle);

      _localStorage.write('user_id', response.user.id);
      _localStorage.write('user_email', response.user.email);
      _localStorage.write('username', response.user.username);
      _localStorage.write('role_title', roleTitle);
      _localStorage.write('user_type', userType.name);

      Get.offAllNamed(
        AppRoutes.main,
        arguments: userType,
      );
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }


}
UserType _mapRoleToUserType(String roleTitle) {
  final role = roleTitle.toLowerCase();

  if (role == 'technician' || role == 'service' || role == 'serviceprovider') {
    return UserType.serviceProvider;
  }

  return UserType.buyer;
}