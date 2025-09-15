import 'package:dio/dio.dart';
import 'package:edusync/core/network/api_url.dart';
import 'package:edusync/core/network/dio_api.dart';
import 'package:edusync/models/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final DioClient client;

  AuthRepository({DioClient? client}) : client = client ?? DioClient();

  /// Gọi API đăng nhập, trả về AuthResponse và lưu token nếu cần
  Future<AuthResponse> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final Response resp = await client.post(
        ApiUrl.login,
        data: {'email': email, 'password': password},
      );
      final data = resp.data as Map<String, dynamic>;
      final auth = AuthResponse.fromMap(data);

      // Lưu token để interceptor có thể tự refresh
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', auth.data.accessToken);
      await prefs.setString('refresh_token', auth.data.refreshToken);
      // Lưu user ID để so sánh với submissions
      await prefs.setString('user_id', auth.data.user.id);
      return auth;
    } on DioException catch (e) {
      final message = _extractMessage(e);
      throw Exception(message);
    }
  }

  String _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}
    return e.message ?? 'Lỗi đăng nhập';
  }

  /// Đăng ký tài khoản mới
  Future<RegisterResponse> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final Response resp = await client.post(
        ApiUrl.register,
        data: {'username': username, 'email': email, 'password': password},
      );
      return RegisterResponse.fromMap(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = _extractMessage(e);
      throw Exception(message);
    }
  }

  /// Đăng xuất: gọi API và xoá token lưu trữ
  Future<void> logout({required String userId}) async {
    try {
      await client.post(ApiUrl.logout, data: {'userId': userId});
    } on DioException catch (e) {
      // Vẫn tiếp tục clear token ngay cả khi API lỗi
      final _ = _extractMessage(e);
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_id');
    }
  }
}
