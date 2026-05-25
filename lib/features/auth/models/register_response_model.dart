class RegisterResponseModel {
  final bool success;
  final String message;
  final RegisterUserModel? data;

  RegisterResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? RegisterUserModel.fromJson(
        Map<String, dynamic>.from(json['data']),
      )
          : null,
    );
  }
}

class RegisterUserModel {
  final String id;
  final String email;

  RegisterUserModel({
    required this.id,
    required this.email,
  });

  factory RegisterUserModel.fromJson(Map<String, dynamic> json) {
    return RegisterUserModel(
      id: json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}




class LoginResponseModel {
  final bool success;
  final String message;
  final String token;
  final LoginUserModel user;

  LoginResponseModel({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      user: LoginUserModel.fromJson(
        Map<String, dynamic>.from(json['user'] ?? {}),
      ),
    );
  }
}

class LoginUserModel {
  final String id;
  final String email;
  final String username;
  final LoginRoleModel? role;
  final String roleModelName;

  LoginUserModel({
    required this.id,
    required this.email,
    required this.username,
    this.role,
    required this.roleModelName,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      role: json['role'] != null
          ? LoginRoleModel.fromJson(
        Map<String, dynamic>.from(json['role']),
      )
          : null,
      roleModelName: json['roleModelName']?.toString() ?? '',
    );
  }
}

class LoginRoleModel {
  final String id;
  final String title;
  final String modelName;
  final List<LoginPermissionModel> permissions;

  LoginRoleModel({
    required this.id,
    required this.title,
    required this.modelName,
    required this.permissions,
  });

  factory LoginRoleModel.fromJson(Map<String, dynamic> json) {
    return LoginRoleModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      modelName: json['modelName']?.toString() ?? '',
      permissions: json['permissions'] is List
          ? (json['permissions'] as List)
          .map(
            (item) => LoginPermissionModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : [],
    );
  }
}

class LoginPermissionModel {
  final String id;
  final String resource;
  final bool canCreate;
  final bool canView;
  final bool canEdit;
  final bool canDelete;

  LoginPermissionModel({
    required this.id,
    required this.resource,
    required this.canCreate,
    required this.canView,
    required this.canEdit,
    required this.canDelete,
  });

  factory LoginPermissionModel.fromJson(Map<String, dynamic> json) {
    return LoginPermissionModel(
      id: json['_id']?.toString() ?? '',
      resource: json['resource']?.toString() ?? '',
      canCreate: json['canCreate'] == true,
      canView: json['canView'] == true,
      canEdit: json['canEdit'] == true,
      canDelete: json['canDelete'] == true,
    );
  }
}