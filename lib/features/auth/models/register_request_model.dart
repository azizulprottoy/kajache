class RegisterRequestModel {
  final String email;
  final String username;
  final String password;
  final String roleTitle;
  final Map<String, dynamic> profileData;

  RegisterRequestModel({
    required this.email,
    required this.username,
    required this.password,
    required this.roleTitle,
    required this.profileData,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
      'roleTitle': roleTitle,
      'profileData': profileData,
    };
  }
}


class LoginRequestModel {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequestModel({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    };
  }
}