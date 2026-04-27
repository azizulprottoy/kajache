import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';

enum UserType {
  buyer,
  serviceProvider,
}

class AuthController extends GetxController {
  final _secureStorage = Get.find<SecureStorageService>();
  final _localStorage = Get.find<LocalStorageService>();

  final RxBool isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  final inputController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool obscurePassword = true.obs;

  static const String buyerEmail = 'buyer@kajache.com';
  static const String buyerPassword = '123456';

  static const String serviceEmail = 'service@kajache.com';
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

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    try {
      final input = inputController.text.trim().toLowerCase();
      final password = passwordController.text;

      await Future.delayed(const Duration(seconds: 1));

      UserType? userType;

      if (input == buyerEmail && password == buyerPassword) {
        userType = UserType.buyer;
      } else if (input == serviceEmail && password == servicePassword) {
        userType = UserType.serviceProvider;
      }

      if (userType == null) {
        isLoading.value = false;
        Get.snackbar(
          'Login Failed',
          'Invalid email or password',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _secureStorage.saveToken('dummy_token_${userType.name}');
      _localStorage.write('user_type', userType.name);

      isLoading.value = false;

      Get.offAllNamed(
        AppRoutes.main,
        arguments: userType,
      );
    } catch (e) {
      if (!isClosed) {
        isLoading.value = false;
        Get.snackbar(
          'error'.tr,
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}