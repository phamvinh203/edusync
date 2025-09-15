import 'package:dio/dio.dart';
import 'package:edusync/core/network/api_url.dart';
import 'package:edusync/core/network/dio_api.dart';
import 'package:edusync/models/exercise_model.dart';

class ExerciseRepository {
  final DioClient client;

  ExerciseRepository({DioClient? client}) : client = client ?? DioClient();

  Future<ExerciseResponse> createExercise({
    required String classId,
    required CreateExerciseRequest payload,
    List<MultipartFile>? files,
  }) async {
    try {
      final url = ApiUrl.createExercise.replaceAll(':classId', classId);
      Response resp;
      // Always use multipart/form-data to match backend expectations
      final map = Map<String, dynamic>.from(payload.toMap());
      if (files != null && files.isNotEmpty) {
        map.remove('attachments');
      }
      final form = FormData.fromMap({
        ...map,
        if (files != null && files.isNotEmpty) 'attachments': files,
      });
      // Let Dio set proper multipart boundary automatically
      resp = await client.post(url, data: form);
      return ExerciseResponse.fromMap(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  Future<List<Exercise>> getExercisesByClass(String classId) async {
    try {
      final url = ApiUrl.getExercisesByClass.replaceAll(':classId', classId);
      final Response resp = await client.get(url);
      final data = resp.data;

      List<dynamic> _extractList(dynamic root) {
        if (root is List) return root;
        if (root is Map) {
          final dynamic level1 =
              root['data'] ??
              root['assignments'] ??
              root['items'] ??
              root['list'] ??
              root['exercises'];
          if (level1 is List) return level1;
          if (level1 is Map) {
            final dynamic level2 =
                level1['data'] ??
                level1['assignments'] ??
                level1['items'] ??
                level1['list'] ??
                level1['exercises'];
            if (level2 is List) return level2;
          }
        }
        return const [];
      }

      // Hỗ trợ nhiều định dạng response khác nhau
      final List<dynamic> list = _extractList(data);
      return list
          .map((e) => Exercise.fromMap(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  String _extractMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      return e.response?.data['message']?.toString() ?? 'Có lỗi xảy ra';
    }
    return e.message ?? 'Có lỗi xảy ra';
  }
}
