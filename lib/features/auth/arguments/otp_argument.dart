class OtpArgument {
  bool? isReset;
  // Account email for the password reset flow
  String? email;

  OtpArgument({this.isReset, this.email});
}

// Passed from the OTP page to the new-password page
class ResetPasswordArgument {
  final String email;
  final String code;

  ResetPasswordArgument({required this.email, required this.code});
}
