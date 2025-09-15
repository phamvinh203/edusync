import 'dart:convert';

/// Model người dùng
class AuthUser {
  final String id;
  final String username;
  final String email;
  final String role;

  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory AuthUser.fromMap(Map<String, dynamic> map) => AuthUser(
    id: (map['_id'] ?? map['id'] ?? '').toString(),
    username: (map['username'] ?? '').toString(),
    email: (map['email'] ?? '').toString(),
    role: (map['role'] ?? '').toString(),
  );
}

/// Gói token + user trong field "data"
class AuthData {
  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  const AuthData({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthData.fromMap(Map<String, dynamic> map) => AuthData(
    accessToken: (map['access_token'] ?? '').toString(),
    refreshToken: (map['refresh_token'] ?? '').toString(),
    user: AuthUser.fromMap((map['user'] as Map<String, dynamic>? ?? {})),
  );
}

/// Response chuẩn theo API: success/message/data
class AuthResponse {
  final bool success;
  final String message;
  final AuthData data;

  const AuthResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AuthResponse.fromMap(Map<String, dynamic> map) => AuthResponse(
    success: map['success'] == true,
    message: (map['message'] ?? '').toString(),
    data: AuthData.fromMap(map['data'] as Map<String, dynamic>? ?? {}),
  );

  static AuthResponse fromJson(String source) =>
      AuthResponse.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Response đăng ký: success/message/data.user
class RegisterResponse {
  final bool success;
  final String message;
  final AuthUser user;

  const RegisterResponse({
    required this.success,
    required this.message,
    required this.user,
  });

  factory RegisterResponse.fromMap(Map<String, dynamic> map) {
    final data = map['data'] as Map<String, dynamic>? ?? {};
    final userMap = data['user'] as Map<String, dynamic>? ?? {};
    return RegisterResponse(
      success: map['success'] == true,
      message: (map['message'] ?? '').toString(),
      user: AuthUser.fromMap(userMap),
    );
  }
}
