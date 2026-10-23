import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/error/api_error.dart';
import '../../../core/utils/app_services.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/success_model.dart';
import '../arguments/otp_argument.dart';
import '../repository/auth_repository.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  final _repository = AuthRepository();
  // Email + verified code from the OTP page
  ResetPasswordArgument? _resetArgument;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is ResetPasswordArgument) {
      _resetArgument = args;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Get.offNamed(AppRoutes.forgotPasswordEmail);
      });
    }
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final reset = _resetArgument;
    if (reset == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      await _repository.resetPassword(
        reset.email,
        reset.code,
        newPasswordController.text,
      );
    } catch (e) {
      AppServices.showError(apiErrorMessage(e, fallback: 'Could not reset the password'));
      return;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => SuccessModal(
        title: TKeys.success.tr,
        message: TKeys.passwordResetSuccess.tr,
        yesText: TKeys.ok.tr,

        onYes: () {
           Get.offAllNamed(AppRoutes.login);      },
        onNo: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  TKeys.resetPassword.tr,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  TKeys.createNewPassword.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: TKeys.newPassword.tr,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return TKeys.newPasswordRequired.tr;
                    }
                    if (value.length < 6) {
                      return TKeys.passwordMin.tr;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: TKeys.confirmPassword.tr,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
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
                    if (value != newPasswordController.text) {
                      return TKeys.passwordsDoNotMatch.tr;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colorScheme.onPrimary,
                      ),
                    )
                        : Text(
                      TKeys.resetPassword.tr,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}