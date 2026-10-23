import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/error/api_error.dart';
import '../../../core/utils/app_services.dart';
import '../../../core/utils/translation_keys.dart';
import '../arguments/otp_argument.dart';
import '../repository/auth_repository.dart';

/// First step of the password reset: ask for the account email and have the
/// API send a 6-digit code to it. Opened from the login page, which passes
/// whatever was typed in its email field as the argument.
class ForgotPasswordEmailPage extends StatefulWidget {
  const ForgotPasswordEmailPage({super.key});

  @override
  State<ForgotPasswordEmailPage> createState() =>
      _ForgotPasswordEmailPageState();
}

class _ForgotPasswordEmailPageState extends State<ForgotPasswordEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = AuthRepository();
  late final TextEditingController _emailController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final initial = Get.arguments;
    _emailController = TextEditingController(
      text: initial is String && GetUtils.isEmail(initial) ? initial : '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final email = _emailController.text.trim().toLowerCase();
    setState(() => isLoading = true);
    try {
      await _repository.forgotPassword(email);
      AppServices.showSuccess(TKeys.resetCodeSent.tr);
      Get.toNamed(
        AppRoutes.otpPage,
        arguments: OtpArgument(isReset: true, email: email),
      );
    } catch (e) {
      AppServices.showError(apiErrorMessage(e, fallback: 'Could not send the code'));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
                  TKeys.forgotPasswordInfo.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  onFieldSubmitted: (_) => isLoading ? null : _submit(),
                  decoration: InputDecoration(
                    labelText: TKeys.email.tr,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    final val = v?.trim() ?? '';
                    if (val.isEmpty) return TKeys.emailRequired.tr;
                    if (!GetUtils.isEmail(val)) return TKeys.invalidEmail.tr;
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
                            TKeys.sendCode.tr,
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
