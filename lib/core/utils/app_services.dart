import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../error/failure.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class AppServices {
  AppServices._();

  // ── Snackbars ───────────────────────────────────────────────────────────────
  static void showSuccess(String message, {String title = 'Success'}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.success.withOpacity(0.9),
      colorText: AppColors.white,
      icon: const Icon(Icons.check_circle, color: AppColors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }

  static void showError(String message, {String title = 'Error'}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.error.withOpacity(0.9),
      colorText: AppColors.white,
      icon: const Icon(Icons.error_outline, color: AppColors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 4),
    );
  }

  static void showWarning(String message, {String title = 'Warning'}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.warning.withOpacity(0.9),
      colorText: AppColors.white,
      icon: const Icon(Icons.warning_amber, color: AppColors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.info.withOpacity(0.9),
      colorText: AppColors.white,
      icon: const Icon(Icons.info_outline, color: AppColors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }

  // ── API Failure handler ─────────────────────────────────────────────────────
  static void showApiFailure({required Failure failure}) {
    showError(failure.message);
  }

  // ── Loading Dialog ──────────────────────────────────────────────────────────
  static void showLoading({String message = 'Please wait...'}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(message, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  // ── Confirm Dialog ──────────────────────────────────────────────────────────
  static Future<bool?> showConfirm({
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'Cancel',
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(title, style: AppTextStyles.heading3),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // ── Unauthorized (401) ──────────────────────────────────────────────────────
  static void handleUnauthorized() {
    showError('Session expired. Please login again.');
    Get.offAllNamed(AppRoutes.login);
  }
}