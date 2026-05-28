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

class RegisterController extends GetxController {
  final _authRepository = Get.find<AuthRepository>();

  final RxBool isLoading = false.obs;

  final formKey = GlobalKey<FormState>();

  final inputController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
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