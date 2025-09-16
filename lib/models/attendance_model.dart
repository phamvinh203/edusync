import 'dart:convert';

class AttendanceStudentEntry {
  final String studentId; // can be id or populated object id
  final String status; // present|absent|late? (backend: present/absent)
  final String? id; // entry _id
  final DateTime? markedAt;

  const AttendanceStudentEntry({
    required this.studentId,
    required this.status,
    this.id,
    this.markedAt,
  });

  factory AttendanceStudentEntry.fromMap(Map<String, dynamic> map) {
    // Backend may populate studentId with object { _id, ... }
    final rawStudent = map['studentId'];
    final sid =
        rawStudent is Map<String, dynamic>
            ? (rawStudent['_id'] ?? rawStudent['id'] ?? '').toString()
            : (rawStudent ?? '').toString();

    return AttendanceStudentEntry(
      studentId: sid,
      status: (map['status'] ?? '').toString(),
      id: (map['_id'] ?? map['id'])?.toString(),
      markedAt:
          map['markedAt'] != null
              ? DateTime.tryParse(map['markedAt'].toString())
              : null,
    );
  }

  Map<String, dynamic> toMap() => {'studentId': studentId, 'status': status};
}

class AttendanceSession {
  final String id;
  final String classId;
  final String teacherId;
  final List<AttendanceStudentEntry> students;
  final String status; // open|closed
  final DateTime date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AttendanceSession({
    required this.id,
    required this.classId,
    required this.teacherId,
    required this.students,
    required this.status,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory AttendanceSession.fromMap(
    Map<String, dynamic> map,
  ) => AttendanceSession(
    id: (map['_id'] ?? map['id'] ?? '').toString(),
    classId: (map['classId'] ?? '').toString(),
    teacherId: (map['teacherId'] ?? '').toString(),
    students:
        (map['students'] as List<dynamic>? ?? [])
            .map(
              (e) => AttendanceStudentEntry.fromMap(e as Map<String, dynamic>),
            )
            .toList(),
    status: (map['status'] ?? '').toString(),
    date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
    createdAt:
        map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'].toString())
            : null,
    updatedAt:
        map['updatedAt'] != null
            ? DateTime.tryParse(map['updatedAt'].toString())
            : null,
  );
}

class StartAttendanceResponse {
  final String message;
  final AttendanceSession data;

  const StartAttendanceResponse({required this.message, required this.data});

  factory StartAttendanceResponse.fromMap(Map<String, dynamic> map) =>
      StartAttendanceResponse(
        message: (map['message'] ?? '').toString(),
        data: AttendanceSession.fromMap(map['data'] as Map<String, dynamic>),
      );

  static StartAttendanceResponse fromJson(String source) =>
      StartAttendanceResponse.fromMap(
        jsonDecode(source) as Map<String, dynamic>,
      );
}

class MarkAttendanceResponse {
  final String message;
  final AttendanceSession data;

  const MarkAttendanceResponse({required this.message, required this.data});

  factory MarkAttendanceResponse.fromMap(Map<String, dynamic> map) =>
      MarkAttendanceResponse(
        message: (map['message'] ?? '').toString(),
        data: AttendanceSession.fromMap(map['data'] as Map<String, dynamic>),
      );
}

class AttendanceHistoryResponse {
  final String message;
  final List<AttendanceSession> data;

  const AttendanceHistoryResponse({required this.message, required this.data});

  factory AttendanceHistoryResponse.fromMap(Map<String, dynamic> map) =>
      AttendanceHistoryResponse(
        message: (map['message'] ?? '').toString(),
        data:
            (map['data'] as List<dynamic>? ?? [])
                .map(
                  (e) => AttendanceSession.fromMap(e as Map<String, dynamic>),
                )
                .toList(),
      );
}
