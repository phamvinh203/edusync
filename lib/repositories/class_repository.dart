import 'package:dio/dio.dart';
import 'package:edusync/core/network/api_url.dart';
import 'package:edusync/core/network/dio_api.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/models/users_model.dart';

class ClassRepository {
  final DioClient client;

  ClassRepository({DioClient? client}) : client = client ?? DioClient();

  /// Tạo lớp học mới
  Future<CreateClassResponse> createClass({
    required String nameClass,
    required String subject,
    String? description,
    required List<Schedule> schedule,
    String? location,
    int? maxStudents,
    String? gradeLevel,
    double? pricePerSession,
  }) async {
    try {
      final data = {
        'nameClass': nameClass,
        'subject': subject,
        if (description != null && description.isNotEmpty)
          'description': description,
        'schedule': schedule.map((s) => s.toMap()).toList(),
        if (location != null && location.isNotEmpty) 'location': location,
        if (maxStudents != null) 'maxStudents': maxStudents,
        if (gradeLevel != null && gradeLevel.isNotEmpty)
          'gradeLevel': gradeLevel,
        if (pricePerSession != null) 'pricePerSession': pricePerSession,
      };

      final Response resp = await client.post(ApiUrl.createClass, data: data);

      return CreateClassResponse.fromMap(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  /// Lấy danh sách tất cả lớp học
  Future<List<ClassModel>> getAllClasses() async {
    try {
      final Response resp = await client.get(ApiUrl.getListClasses);

      // Xử lý response data
      final responseData = resp.data;
      List<dynamic> classesData;

      if (responseData is Map<String, dynamic>) {
        // Nếu API trả về object với key 'data' hoặc 'classes'
        classesData = responseData['data'] ?? responseData['classes'] ?? [];
      } else if (responseData is List) {
        // Nếu API trả về array trực tiếp
        classesData = responseData;
      } else {
        throw Exception('Định dạng dữ liệu không hợp lệ');
      }

      return classesData
          .map((json) => ClassModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  /// Lấy chi tiết lớp học theo ID
  Future<ClassDetailsResponse> getClassDetails(String classId) async {
    try {
      final Response resp = await client.get(
        '${ApiUrl.getClassDetails}/$classId',
      );
      return ClassDetailsResponse.fromMap(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  /// Lấy danh sách học sinh trong lớp
  Future<ClassStudentsResponse> getClassStudents(String classId) async {
    try {
      final url = ApiUrl.getStudentClass.replaceAll(':classId', classId);
      final Response resp = await client.get(url);
      return ClassStudentsResponse.fromMap(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  /// Lấy danh sách học sinh chờ duyệt
  Future<PendingStudentsResponse> getPendingStudents(String classId) async {
    try {
      final url = ApiUrl.getPendingStudentClass.replaceAll(':classId', classId);
      final Response resp = await client.get(url);
      return PendingStudentsResponse.fromMap(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  /// Duyệt học sinh vào lớp
  Future<ApproveStudentResponse> approveStudent(
    String classId,
    String studentId,
  ) async {
    try {
      final url = ApiUrl.postApproveStudent
          .replaceAll(':classId', classId)
          .replaceAll(':studentId', studentId);
      final Response resp = await client.post(url);
      return ApproveStudentResponse.fromMap(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  /// Xóa lớp học
  Future<DeleteClassResponse> deleteClass(String classId) async {
    try {
      final url = ApiUrl.deleteClass.replaceAll(':id', classId);
      final data = await client.delete(url);
      return DeleteClassResponse.fromMap(data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  /// Đăng ký tham gia lớp học (dành cho student)
  Future<JoinClassResponse> joinClass(String classId) async {
    try {
      final url = ApiUrl.joinClassStudent.replaceAll(':id', classId);
      final Response resp = await client.post(url);
      return JoinClassResponse.fromMap(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  /// Lấy số lượng lớp gia sư mà học sinh đã đăng ký
  Future<int> getMyRegisteredClassesCount() async {
    try {
      final Response resp = await client.get(ApiUrl.getMyRegisteredClasses);
      final responseData = resp.data as Map<String, dynamic>;
      return responseData['totalClasses'] is int
          ? responseData['totalClasses']
          : 0;
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  /// Lấy danh sách lớp học mà học sinh đã đăng ký và đang chờ phê duyệt
  Future<List<ClassModel>> getMyPendingClasses() async {
    try {
      final Response resp = await client.get(ApiUrl.getMyPendingClasses);
      final responseData = resp.data as Map<String, dynamic>;
      final raw = responseData['data'] ?? [];

      return (raw as List)
          .map((json) => ClassModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  /// Lấy danh sách lớp học mà học sinh đã đăng ký
  Future<List<ClassModel>> getMyRegisteredClasses() async {
    try {
      final Response resp = await client.get(ApiUrl.getMyRegisteredClasses);
      final responeData = resp.data as Map<String, dynamic>;
      final raw = responeData['data'] ?? responeData['classes'] ?? [];
      // Chỉ giữ các lớp có trạng thái duyệt thành công (approved)
      final filtered =
          (raw as List)
              .where(
                (e) =>
                    (e is Map<String, dynamic>) &&
                    ((e['registrationInfo']
                                as Map<String, dynamic>?)?['status'])
                            ?.toString()
                            .toLowerCase() ==
                        'approved',
              )
              .toList();
      return filtered
          .map((json) => ClassModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  /// Học sinh rời khỏi lớp học
  Future<LeaveClassResponse> leaveClass(String classId) async {
    try {
      final url = ApiUrl.postLeaveClass.replaceAll(':classId', classId);
      final Response resp = await client.post(url);
      return LeaveClassResponse.fromMap(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      throw Exception(msg);
    }
  }

  String _extractMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      return e.response?.data['message'] ?? 'Có lỗi xảy ra';
    }
    return e.message ?? 'Có lỗi xảy ra';
  }
}
