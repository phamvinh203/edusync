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

  Future<Exercise> getExerciseDetails({
    required String classId,
    required String exerciseId,
  }) async {
    try {
      final url = ApiUrl.getExerciseDetails
          .replaceAll(':classId', classId)
          .replaceAll(':exerciseId', exerciseId);
      final Response resp = await client.get(url);
      final data = resp.data;
      Map<String, dynamic>? map;
      if (data is Map<String, dynamic>) {
        if (data['data'] is Map<String, dynamic>) {
          map = data['data'] as Map<String, dynamic>;
        } else if (data['exercise'] is Map<String, dynamic>) {
          map = data['exercise'] as Map<String, dynamic>;
        } else {
          map = data;
        }
      }
      if (map == null) {
        throw Exception('Dữ liệu bài tập không hợp lệ');
      }
      return Exercise.fromMap(map);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  Future<SubmitExerciseResponse> submitExercise({
    required String classId,
    required String exerciseId,
    String? content,
    MultipartFile? file,
  }) async {
    try {
      if ((content == null || content.trim().isEmpty) && file == null) {
        throw Exception('Vui lòng nhập nội dung hoặc chọn tệp để nộp.');
      }
      final url = ApiUrl.submitExercise
          .replaceAll(':classId', classId)
          .replaceAll(':exerciseId', exerciseId);
      final form = FormData.fromMap({
        if (content != null && content.trim().isNotEmpty) 'content': content,
        if (file != null) 'file': file,
      });
      final Response resp = await client.post(url, data: form);
      return SubmitExerciseResponse.fromMap(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  // Lấy danh sách bài nộp của một bài tập (dành cho giáo viên)
  Future<List<Submission>> getSubmissions({
    required String classId,
    required String exerciseId,
  }) async {
    try {
      final url = ApiUrl.getSubmissions
          .replaceAll(':classId', classId)
          .replaceAll(':exerciseId', exerciseId);
      final Response resp = await client.get(url);
      final data = resp.data;

      List<dynamic> extractList(dynamic root) {
        if (root is List) return root;
        if (root is Map) {
          final level1 = root['data'] ?? root['submissions'] ?? root['items'];
          if (level1 is List) return level1;
          if (level1 is Map) {
            final level2 =
                level1['submissions'] ?? level1['items'] ?? level1['data'];
            if (level2 is List) return level2;
          }
        }
        return const [];
      }

      final List<dynamic> list = extractList(data);
      return list
          .map((e) => Submission.fromMap(e as Map<String, dynamic>))
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

  // Chấm điểm bài nộp (giáo viên)
  Future<Submission> gradeSubmission({
    required String classId,
    required String exerciseId,
    required String submissionId,
    required double grade,
    String? feedback,
  }) async {
    try {
      final url = ApiUrl.gradeSubmission
          .replaceAll(':classId', classId)
          .replaceAll(':exerciseId', exerciseId)
          .replaceAll(':submissionId', submissionId);

      final payload = {
        'grade': grade,
        if (feedback != null && feedback.trim().isNotEmpty)
          'feedback': feedback.trim(),
      };

      final Response resp = await client.put(url, data: payload);
      final data = resp.data;

      Map<String, dynamic>? map;
      if (data is Map<String, dynamic>) {
        if (data['data'] is Map<String, dynamic>) {
          map = data['data'] as Map<String, dynamic>;
        } else {
          map = data;
        }
      }
      if (map == null) throw Exception('Dữ liệu chấm điểm không hợp lệ');
      return Submission.fromMap(map);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }
}
