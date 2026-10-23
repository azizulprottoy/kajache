import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/error/api_error.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../core/utils/app_services.dart';
import '../../../shared/widgets/success_model.dart';
import '../arguments/otp_argument.dart';
import '../repository/auth_repository.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  OtpArgument? otpArgument;
  final _repository = AuthRepository();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is OtpArgument) {
      otpArgument = args;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Get.back();
        AppServices.showError('Could not open verification. Please try again.');
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get otp => _controllers.map((e) => e.text).join();

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _onBackspace(String value, int index) {
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyResetCode(String email) async {
    setState(() => isLoading = true);
    try {
      await _repository.verifyResetCode(email, otp);
      Get.offNamed(
        AppRoutes.forgotPassword,
        arguments: ResetPasswordArgument(email: email, code: otp),
      );
    } catch (e) {
      AppServices.showError(apiErrorMessage(e, fallback: 'Invalid or expired code'));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resend() async {
    final email = otpArgument?.email;
    if (otpArgument?.isReset != true || email == null) return;
    try {
      await _repository.forgotPassword(email);
      AppServices.showSuccess(TKeys.resetCodeSent.tr);
    } catch (e) {
      AppServices.showError(apiErrorMessage(e, fallback: 'Could not send the code'));
    }
  }

  void _verifyOtp() {
    if (otp.length != 6) {
      Get.snackbar(
        TKeys.error.tr,
        TKeys.enterOtp.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final isReset = otpArgument?.isReset ?? false;

    if (isReset) {
      final email = otpArgument?.email;
      if (email == null) {
        Get.offNamed(AppRoutes.forgotPasswordEmail);
        return;
      }
      _verifyResetCode(email);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessModal(
        title: TKeys.success.tr,
        message: TKeys.accountVerified.tr,
        yesText: TKeys.ok.tr,
        onYes: () {
          Navigator.of(context).pop();
          Get.offAllNamed(AppRoutes.login);
        },
        onClose: () {
          Navigator.of(context).pop();
          Get.offAllNamed(AppRoutes.login);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                TKeys.verifyOtp.tr,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                TKeys.otpSentInfo.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                      (index) => Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: SizedBox(
                    width: 48,
                    height: 56,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isEmpty) {
                          _onBackspace(value, index);
                        } else {
                          _onChanged(value, index);
                        }
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: isLoading ? null : _verifyOtp,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    TKeys.verify.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: _resend,
                  child: Text(
                    TKeys.resendOtp.tr,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}