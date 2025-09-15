import 'package:dio/dio.dart';
import 'package:edusync/core/network/api_url.dart';
import 'package:edusync/core/network/dio_api.dart';
import 'package:edusync/models/schedule_model.dart';

class ScheduleRepository {
  final DioClient client;

  ScheduleRepository({DioClient? client}) : client = client ?? DioClient();

  /// Lấy lịch học của các lớp đã tham gia
  Future<ScheduleResponseModel> getClassSchedules() async {
    try {
      final response = await client.get(ApiUrl.createSchedule);

      if (response.statusCode == 200 && response.data != null) {
        return ScheduleResponseModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to get class schedules: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        String errorMessage = 'Unknown error';

        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData is String) {
          errorMessage = errorData;
        }

        throw Exception('Error ${e.response!.statusCode}: $errorMessage');
      } else {
        throw Exception('Network error: ${e.message ?? 'Connection failed'}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
