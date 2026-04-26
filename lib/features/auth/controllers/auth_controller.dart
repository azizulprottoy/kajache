import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';

class AuthController extends GetxController {
  final _secureStorage = Get.find<SecureStorageService>();
  final _localStorage  = Get.find<LocalStorageService>();
  RxBool isLoading = false.obs;
  final formKey          = GlobalKey<FormState>();
  final inputController  = TextEditingController();
  final passwordController = TextEditingController();
  RxBool obscurePassword = true.obs;

  @override
  void onClose() {
    inputController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2));

    final isFirstTime = !_localStorage.isOnboardingDone;
    if (isFirstTime) {
      Get.toNamed(AppRoutes.login);
      return;
    }

    final token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      Get.toNamed(AppRoutes.login);
    } else {
      Get.toNamed(AppRoutes.login);
    }
  }

  void toggleObscurePassword() => obscurePassword.value = !obscurePassword.value;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final input    = inputController.text.trim();
      final password = passwordController.text;

      await Future.delayed(const Duration(seconds: 1));

      await _secureStorage.saveToken('your_token_here');
      Get.toNamed(AppRoutes.main);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      Get.toNamed(AppRoutes.main);

    } finally {
      isLoading.value = false;
    }
  }
}