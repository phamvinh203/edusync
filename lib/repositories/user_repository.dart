import 'package:dio/dio.dart';
import 'package:edusync/core/network/api_url.dart';
import 'package:edusync/core/network/dio_api.dart';
import 'package:edusync/models/users_model.dart';

class UserRepository {
  final DioClient client;

  UserRepository({DioClient? client}) : client = client ?? DioClient();

  Future<MeResponse> getMe() async {
    try {
      final Response resp = await client.get(ApiUrl.getUserProfile);
      return MeResponse.fromMap(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  String _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}
    return e.message ?? 'Lỗi gọi thông tin người dùng';
  }
}
