import 'package:dio/dio.dart';
import 'package:edusync/core/network/api_url.dart';
import 'package:edusync/core/network/dio_api.dart';
import 'package:edusync/models/users_model.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

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

  /// Upload avatar bằng multipart/form-data tới endpoint `users/me/avatar`
  /// Trả về URL avatar mới (server trả về trong data.avatarUrl)
  Future<String> updateAvatarFromPath(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Tệp không tồn tại: $filePath');
      }

      final fileName = file.path.split(Platform.pathSeparator).last;
      final mime = lookupMimeType(file.path) ?? 'application/octet-stream';
      final typeParts = mime.split('/');
      final mediaType = MediaType(
        typeParts.first,
        typeParts.length > 1 ? typeParts[1] : 'octet-stream',
      );

      final formData = FormData.fromMap({
        // Backend multer: upload.single('avatar')
        'avatar': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: mediaType,
        ),
      });

      final resp = await client.post(
        ApiUrl.updateAvatar,
        data: formData,
        // Không set contentType thủ công để Dio tự thêm boundary
        onSendProgress: (sent, total) {},
      );

      final data = resp.data;
      if (data is Map<String, dynamic>) {
        final inner = (data['data'] as Map<String, dynamic>?) ?? {};
        final url = (inner['avatarUrl'] ?? '').toString();
        if (url.isEmpty) {
          throw Exception(
            data['message']?.toString() ?? 'Không nhận được avatarUrl',
          );
        }
        return url;
      }
      throw Exception('Phản hồi không hợp lệ');
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

  Future<void> logout() async {
    try {
      await client.post(ApiUrl.logout);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }
}
