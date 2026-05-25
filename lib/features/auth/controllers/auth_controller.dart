import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../arguments/otp_argument.dart';
import '../models/register_request_model.dart';
import '../repository/auth_repository.dart';

enum UserType {
  buyer,
  serviceProvider,
}

class AuthController extends GetxController {
  final _secureStorage = Get.find<SecureStorageService>();
  final _localStorage = Get.find<LocalStorageService>();
  final _authRepository = Get.find<AuthRepository>();
  final RxBool isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  final inputController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool obscurePassword = true.obs;

  static const String buyerEmail = 'buyer@gmail.com';
  static const String buyerPassword = '123456';

  static const String serviceEmail = 'service@gmail.com';
  static const String servicePassword = '123456';

  @override
  void onClose() {
    inputController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() {
    if (!formKey.currentState!.validate()) {
      return Future.value();
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    final request = LoginRequestModel(
      email: inputController.text.trim().toLowerCase(),
      password: passwordController.text,
    );

    return _authRepository
        .login(request)
        .then((response) async {
      if (!response.success) {
        Get.snackbar(
          'Login Failed',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
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

      Get.offAllNamed(
        AppRoutes.main,
        arguments: userType,
      );
    })
        .catchError((error) {
      Get.snackbar(
        'Error',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    })
        .whenComplete(() {
      isLoading.value = false;
    });
  }
  Future<void> register({
    required String accountType,
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    if (!formKey.currentState!.validate()) {
      return Future.value();
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    final roleTitle = accountType == 'buyer'
        ? 'customer'
        : 'technician';

    final request = RegisterRequestModel(
      email: email.trim().toLowerCase(),
      username: email.trim().split('@').first,
      password: password,
      roleTitle: roleTitle,
      profileData: {
        'fullName': fullName.trim(),
        'phone': phone.trim(),
      },
    );

    return _authRepository
        .register(request)
        .then((response) {
      if (response.success) {
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.toNamed(
          AppRoutes.login,

        );
      } else {
        Get.snackbar(
          'Register Failed',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    })
        .catchError((error) {
      Get.snackbar(
        'Error',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    })
        .whenComplete(() {
      isLoading.value = false;
    });
  }
}
UserType _mapRoleToUserType(String roleTitle) {
  final role = roleTitle.toLowerCase();

  if (role == 'technician' || role == 'service' || role == 'serviceprovider') {
    return UserType.serviceProvider;
  }

  return UserType.buyer;
}