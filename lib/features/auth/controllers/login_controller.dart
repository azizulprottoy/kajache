import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaj_ache/features/auth/controllers/register_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/error/api_error.dart';
import '../../../core/notifications/push_notification_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/utils/app_services.dart';
import '../models/register_request_model.dart';
import '../repository/auth_repository.dart';



const rememberMeKey = 'remember_me';

class LoginController extends GetxController {
  final _secureStorage = Get.find<SecureStorageService>();
  final _localStorage = Get.find<LocalStorageService>();
  final _authRepository = Get.find<AuthRepository>();

  final RxBool isLoading = false.obs;

  final inputController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool rememberMe = false.obs;

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login(GlobalKey<FormState> formKey) async {
    if (formKey.currentState?.validate() != true) return;

    FocusManager.instance.primaryFocus?.unfocus();

    try {
      isLoading.value = true;

      final request = LoginRequestModel(
        email: inputController.text.trim().toLowerCase(),
        password: passwordController.text,
        rememberMe: rememberMe.value,
      );

      final response = await _authRepository.login(request);

      if (!response.success) {
        AppServices.showError(
          response.message.isNotEmpty ? response.message : 'Login failed',
        );
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
      // Without "remember me" the session ends on the next app launch
      _localStorage.write(rememberMeKey, rememberMe.value);

      Get.offAllNamed(
        AppRoutes.main,
        arguments: userType,
      );
      PushNotificationService.to.onSignedIn();
    } catch (e) {
      AppServices.showError(apiErrorMessage(e, fallback: 'Login failed'));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    inputController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
UserType _mapRoleToUserType(String roleTitle) {
  final role = roleTitle.toLowerCase();

  if (role == 'technician' || role == 'service' || role == 'serviceprovider') {
    return UserType.serviceProvider;
  }

  return UserType.buyer;
}