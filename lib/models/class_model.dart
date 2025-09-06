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
    teacherId: map['teacherId']?.toString(),
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
