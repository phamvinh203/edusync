import 'dart:convert';

// Model cho lịch học
class Schedule {
  final String? id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  const Schedule({
    this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) => Schedule(
    id: map['_id']?.toString(),
    dayOfWeek: (map['dayOfWeek'] ?? '').toString(),
    startTime: (map['startTime'] ?? '').toString(),
    endTime: (map['endTime'] ?? '').toString(),
  );

  Map<String, dynamic> toMap() => {
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
  };
}

// Model cho lớp học
class ClassModel {
  final String? id;
  final String nameClass;
  final String subject;
  final String? description;
  final String? teacherId;
  final String? teacherName; 
  final List<Schedule> schedule;
  final String? location;
  final int? maxStudents;
  final List<String> pendingStudents;
  final List<String> students;
  final String? createdBy;
  final bool deleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ClassModel({
    this.id,
    required this.nameClass,
    required this.subject,
    this.description,
    this.teacherId,
    this.teacherName,
    this.schedule = const [],
    this.location,
    this.maxStudents,
    this.pendingStudents = const [],
    this.students = const [],
    this.createdBy,
    this.deleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map) => ClassModel(
    id: map['_id']?.toString(),
    nameClass: (map['nameClass'] ?? '').toString(),
    subject: (map['subject'] ?? '').toString(),
    description: map['description']?.toString(),
    teacherId: _getTeacherId(map),
    teacherName: _getTeacherName(map),
    schedule:
        (map['schedule'] as List<dynamic>?)
            ?.map((x) => Schedule.fromMap(x as Map<String, dynamic>))
            .toList() ??
        [],
    location: map['location']?.toString(),
    maxStudents: map['maxStudents'] is int ? map['maxStudents'] : null,
    pendingStudents:
        (map['pendingStudents'] as List<dynamic>?)
            ?.map((x) => x.toString())
            .toList() ??
        [],
    students:
        (map['students'] as List<dynamic>?)
            ?.map((x) => x.toString())
            .toList() ??
        [],
    createdBy: map['createdBy']?.toString(),
    deleted: map['deleted'] == true,
    createdAt:
        map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'].toString())
            : null,
    updatedAt:
        map['updatedAt'] != null
            ? DateTime.tryParse(map['updatedAt'].toString())
            : null,
  );

  /// Hàm helper để lấy teacherId từ nhiều định dạng khác nhau
  static String? _getTeacherId(Map<String, dynamic> map) {
    if (map['teacherId'] is Map<String, dynamic>) {
      final teacherObj = map['teacherId'] as Map<String, dynamic>;
      return teacherObj['_id']?.toString();
    }
    return map['teacherId']?.toString();
  }

  /// Hàm helper để lấy tên giáo viên từ nhiều nguồn khác nhau
  static String? _getTeacherName(Map<String, dynamic> map) {
    // Trường hợp teacherId là object có username (như API trả về)
    if (map['teacherId'] is Map<String, dynamic>) {
      final teacherObj = map['teacherId'] as Map<String, dynamic>;
      if (teacherObj['username'] != null &&
          teacherObj['username'].toString().isNotEmpty) {
        return teacherObj['username'].toString();
      }
      if (teacherObj['name'] != null &&
          teacherObj['name'].toString().isNotEmpty) {
        return teacherObj['name'].toString();
      }
    }

    // Thử trường teacherName trực tiếp
    if (map['teacherName'] != null &&
        map['teacherName'].toString().isNotEmpty) {
      return map['teacherName'].toString();
    }

    // Thử trường teacher object
    if (map['teacher'] is Map<String, dynamic>) {
      final teacher = map['teacher'] as Map<String, dynamic>;
      if (teacher['username'] != null &&
          teacher['username'].toString().isNotEmpty) {
        return teacher['username'].toString();
      }
      if (teacher['name'] != null && teacher['name'].toString().isNotEmpty) {
        return teacher['name'].toString();
      }
    }

    // Fallback cuối cùng
    if (map['createdByName'] != null &&
        map['createdByName'].toString().isNotEmpty) {
      return map['createdByName'].toString();
    }

    return null;
  }

  Map<String, dynamic> toMap() => {
    'nameClass': nameClass,
    'subject': subject,
    if (description != null) 'description': description,
    'schedule': schedule.map((x) => x.toMap()).toList(),
    if (location != null) 'location': location,
    if (maxStudents != null) 'maxStudents': maxStudents,
  };
}

// Response cho API tạo lớp học
class CreateClassResponse {
  final String message;
  final ClassModel data;

  const CreateClassResponse({required this.message, required this.data});

  factory CreateClassResponse.fromMap(Map<String, dynamic> map) =>
      CreateClassResponse(
        message: (map['message'] ?? '').toString(),
        data: ClassModel.fromMap(map['data'] as Map<String, dynamic>),
      );

  static CreateClassResponse fromJson(String source) =>
      CreateClassResponse.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

// Response cho API lấy chi tiết lớp học
class ClassDetailsResponse {
  final String message;
  final ClassModel data;

  const ClassDetailsResponse({required this.message, required this.data});

  factory ClassDetailsResponse.fromMap(Map<String, dynamic> map) =>
      ClassDetailsResponse(
        message: (map['message'] ?? '').toString(),
        data: ClassModel.fromMap(map['data'] as Map<String, dynamic>),
      );

  static ClassDetailsResponse fromJson(String source) =>
      ClassDetailsResponse.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

// Response cho API xóa lớp học
class DeleteClassResponse {
  final String message;
  final ClassModel data;

  const DeleteClassResponse({required this.message, required this.data});

  factory DeleteClassResponse.fromMap(Map<String, dynamic> map) =>
      DeleteClassResponse(
        message: (map['message'] ?? '').toString(),
        data: ClassModel.fromMap(map['data'] as Map<String, dynamic>),
      );

  static DeleteClassResponse fromJson(String source) =>
      DeleteClassResponse.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

