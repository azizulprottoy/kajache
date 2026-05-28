import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaj_ache/core/utils/translation_keys.dart';
import '../arguments/otp_argument.dart';
import '../controllers/login_controller.dart';
import '../../../app/routes/app_routes.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              Image.asset(
                'assets/images/logo.png',
                height: 100,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 100),
              Text(
                TKeys.welcomeBack.tr,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 32),

              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.inputController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: TKeys.emailOrPhone.tr,
                        hintText: TKeys.emailOrPhoneHint.tr,
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return TKeys.inputRequired.tr;
                        }
                        final val = v.trim();
                        if (!GetUtils.isEmail(val) &&
                            !GetUtils.isPhoneNumber(val)) {
                          return TKeys.inputInvalid.tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.obscurePassword.value,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => controller.login(),
                        decoration: InputDecoration(
                          labelText: TKeys.password.tr,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscurePassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: controller.toggleObscurePassword,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return TKeys.passwordRequired.tr;
                          }
                          if (v.length < 6) return TKeys.passwordMin.tr;
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.toNamed(
                      AppRoutes.otpPage,
                      arguments: OtpArgument(isReset: true),
                    ),
                    child: Text(
                      TKeys.forgotPassword.tr,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.login,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            TKeys.login.tr,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    TKeys.noAccount.tr,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.register),
                    child: Text(
                      TKeys.signUp.tr,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
