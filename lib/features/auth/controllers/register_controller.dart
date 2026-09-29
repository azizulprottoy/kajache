import 'package:kaj_ache/core/error/api_error.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../models/register_request_model.dart';
import '../repository/auth_repository.dart';

enum UserType {
  buyer,
  serviceProvider,
}

class RegisterController extends GetxController {
  final _authRepository = Get.find<AuthRepository>();

  final RxBool isLoading = false.obs;

  /// Returns to the login page without stacking a second LoginPage
  /// (which would duplicate its GlobalKeys).
  static void backToLogin() {
    if (Get.previousRoute == AppRoutes.login) {
      Get.back();
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }

  Future<void> register({
    required GlobalKey<FormState> formKey,
    required String accountType,
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    if (formKey.currentState?.validate() != true) {
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
        'phoneNumber': phone.trim(),
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

        backToLogin();
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
        apiErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    })
        .whenComplete(() {
      isLoading.value = false;
    });
  }
}
