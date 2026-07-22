import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaj_ache/core/utils/translation_keys.dart';
import 'package:kaj_ache/features/auth/arguments/otp_argument.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final RxString selectedAccountType = 'buyer'.obs;
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final RxBool obscurePassword = true.obs;
    final RxBool obscureConfirmPassword = true.obs;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: BackButton(color: colorScheme.onSurface),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),

                Text(
                  TKeys.createAccount.tr,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  TKeys.registerSubtitle.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  TKeys.accountType.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                Obx(
                      () => Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _AccountTypeButton(
                            title: TKeys.buyer.tr,
                            isSelected: selectedAccountType.value == 'buyer',
                            onTap: () => selectedAccountType.value = 'buyer',
                          ),
                        ),
                        Expanded(
                          child: _AccountTypeButton(
                            title: TKeys.service.tr,
                            isSelected: selectedAccountType.value == 'service',
                            onTap: () => selectedAccountType.value = 'service',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                TextFormField(
                  controller: fullNameController,
                  keyboardType: TextInputType.none,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: TKeys.fullname.tr,
                    hintText: TKeys.enterFullName.tr,
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return TKeys.nameRequired.tr;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: TKeys.email.tr,
                    hintText: TKeys.enterEmail.tr,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return TKeys.emailRequired.tr;
                    }
                    if (!GetUtils.isEmail(value.trim())) {
                      return TKeys.enterValidEmail.tr;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: TKeys.phone.tr,
                    hintText: TKeys.enterPhone.tr,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return TKeys.phoneRequired.tr;
                    }
                    if (!GetUtils.isPhoneNumber(value.trim())) {
                      return TKeys.enterValidPhone.tr;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                Obx(
                      () => TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword.value,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: TKeys.password.tr,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          obscurePassword.value = !obscurePassword.value;
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return TKeys.passwordRequired.tr;
                      }
                      if (value.length < 6) {
                        return TKeys.passwordMin.tr;
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                Obx(
                      () => TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword.value,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: TKeys.confirmPassword.tr,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          obscureConfirmPassword.value =
                          !obscureConfirmPassword.value;
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return TKeys.confirmPasswordRequired.tr;
                      }
                      if (value != passwordController.text) {
                        return TKeys.passwordsDoNotMatch.tr;
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Obx(
                      () => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      // onPressed: controller.isLoading.value
                      //     ? null
                      //     : () {
                      //   if (!controller.formKey.currentState!.validate()) {
                      //     return;
                      //   }
                      // onPressed: () => Get.toNamed(AppRoutes.otpPage, arguments: OtpArgument(isReset: false)),
                        // TODO: call your register method
                        // Example:
                        // controller.register(
                        //   accountType: selectedAccountType.value,
                        //   email: emailController.text.trim(),
                        //   phone: phoneController.text.trim(),
                        //   password: passwordController.text,
                        // );
                      // },
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                        controller.register(
                          accountType: selectedAccountType.value,
                          fullName: fullNameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          password: passwordController.text,
                        );
                      },
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
                        TKeys.signUp.tr,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      TKeys.haveAccount.tr,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.login),
                      child: Text(
                        TKeys.login.tr,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTypeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}