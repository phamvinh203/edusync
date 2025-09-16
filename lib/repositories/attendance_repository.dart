import 'package:dio/dio.dart';
import 'package:edusync/core/network/api_url.dart';
import 'package:edusync/core/network/dio_api.dart';
import 'package:edusync/models/attendance_model.dart';

class AttendanceRepository {
  final DioClient client;
  AttendanceRepository({DioClient? client}) : client = client ?? DioClient();

  Future<StartAttendanceResponse> startSession(String classId) async {
    try {
      final url = ApiUrl.takeAttendance.replaceAll(':classId', classId);
      final Response resp = await client.post(url);
      return StartAttendanceResponse.fromMap(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  Future<MarkAttendanceResponse> mark(
    String sessionId,
    List<AttendanceStudentEntry> updates,
  ) async {
    try {
      final url = ApiUrl.markAttendance.replaceAll(':sessionId', sessionId);
      final payload = {'students': updates.map((e) => e.toMap()).toList()};
      final Response resp = await client.put(url, data: payload);
      return MarkAttendanceResponse.fromMap(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  Future<AttendanceHistoryResponse> history(String classId) async {
    try {
      final url = ApiUrl.getAttendanceHistory.replaceAll(':classId', classId);
      final Response resp = await client.get(url);
      return AttendanceHistoryResponse.fromMap(
        resp.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      return e.response?.data['message'] ?? 'Có lỗi xảy ra';
    }
    return e.message ?? 'Có lỗi xảy ra';
  }
}
