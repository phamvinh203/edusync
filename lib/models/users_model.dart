import 'dart:convert';

import 'package:edusync/models/class_model.dart';

// Model cho profile người dùng và response /users/me
// Tuân thủ cấu trúc JSON đã mô tả trong đề bài

class MeAuth {
  final String id;
  final String email;
  final String username;

  const MeAuth({required this.id, required this.email, required this.username});

  factory MeAuth.fromMap(Map<String, dynamic> map) => MeAuth(
    id: (map['id'] ?? '').toString(),
    email: (map['email'] ?? '').toString(),
    username: (map['username'] ?? '').toString(),
  );
}

class UserProfile {
  final String? id; // Nếu backend có _id cho document profile
  final String? authId;
  final String? email;
  final String? username;
  final String? phone;
  final String? userClass;
  final String? userSchool;
  final String? address;
  final String? avatar; // URL ảnh
  final DateTime? dateOfBirth;
  final String? gender; // male|female|other

  const UserProfile({
    this.id,
    this.authId,
    this.email,
    this.username,
    this.phone,
    this.userClass,
    this.userSchool,
    this.address,
    this.avatar,
    this.dateOfBirth,
    this.gender,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    id: (map['_id'] ?? map['id'])?.toString(),
    authId: (map['authId'] ?? '').toString(),
    email: (map['email'] ?? '').toString(),
    username: (map['username'] ?? '').toString(),
    phone: (map['phone'] ?? '').toString(),
    userClass: (map['userClass'] ?? '').toString(),
    userSchool: (map['userSchool'] ?? '').toString(),
    address: (map['address'] ?? '').toString(),
    avatar:
        (map['avatar'] ?? '').toString().isEmpty
            ? null
            : (map['avatar'] as String),
    dateOfBirth:
        map['dateOfBirth'] != null && map['dateOfBirth'].toString().isNotEmpty
            ? DateTime.tryParse(map['dateOfBirth'].toString())
            : null,
    gender:
        (map['gender'] ?? '').toString().isEmpty
            ? null
            : (map['gender'] as String),
  );
}

class MeData {
  final MeAuth auth;
  final UserProfile? profile;

  const MeData({required this.auth, this.profile});

  factory MeData.fromMap(Map<String, dynamic> map) => MeData(
    auth: MeAuth.fromMap(map['auth'] as Map<String, dynamic>? ?? {}),
    profile:
        (map['profile'] == null)
            ? null
            : UserProfile.fromMap(map['profile'] as Map<String, dynamic>),
  );
}

class MeResponse {
  final bool success;
  final String message;
  final MeData data;

  const MeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MeResponse.fromMap(Map<String, dynamic> map) => MeResponse(
    success: map['success'] == true,
    message: (map['message'] ?? '').toString(),
    data: MeData.fromMap(map['data'] as Map<String, dynamic>? ?? {}),
  );
}

// Response cho API lấy danh sách học sinh trong lớp
class ClassStudentsResponse {
  final String message;
  final UserProfile teacher;
  final List<UserProfile> students;

  const ClassStudentsResponse({
    required this.message,
    required this.teacher,
    required this.students,
  });

  factory ClassStudentsResponse.fromMap(Map<String, dynamic> map) =>
      ClassStudentsResponse(
        message: map['message']?.toString() ?? '',
        teacher: UserProfile.fromMap(map['teacher'] as Map<String, dynamic>),
        students:
            (map['students'] as List<dynamic>? ?? [])
                .map((x) => UserProfile.fromMap(x as Map<String, dynamic>))
                .toList(),
      );

  static ClassStudentsResponse fromJson(String source) =>
      ClassStudentsResponse.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

// Response cho API lấy danh sách học sinh chờ duyệt
class PendingStudentsResponse {
  final String message;
  final List<UserProfile> data;
  final int totalPending;

  const PendingStudentsResponse({
    required this.message,
    required this.data,
    required this.totalPending,
  });

  factory PendingStudentsResponse.fromMap(Map<String, dynamic> map) =>
      PendingStudentsResponse(
        message: map['message']?.toString() ?? '',
        data:
            (map['data'] as List<dynamic>? ?? [])
                .map((x) => UserProfile.fromMap(x as Map<String, dynamic>))
                .toList(),
        totalPending: map['totalPending'] as int? ?? 0,
      );

  static PendingStudentsResponse fromJson(String source) =>
      PendingStudentsResponse.fromMap(
        jsonDecode(source) as Map<String, dynamic>,
      );
}

// Data cho response approve student
class ApproveStudentData {
  final List<UserProfile> students;
  final List<UserProfile> pendingStudents;
  final int totalStudents;
  final int totalPending;

  const ApproveStudentData({
    required this.students,
    required this.pendingStudents,
    required this.totalStudents,
    required this.totalPending,
  });

  factory ApproveStudentData.fromMap(Map<String, dynamic> map) =>
      ApproveStudentData(
        students:
            (map['students'] as List<dynamic>? ?? [])
                .map((x) => UserProfile.fromMap(x as Map<String, dynamic>))
                .toList(),
        pendingStudents:
            (map['pendingStudents'] as List<dynamic>? ?? [])
                .map((x) => UserProfile.fromMap(x as Map<String, dynamic>))
                .toList(),
        totalStudents: map['totalStudents'] as int? ?? 0,
        totalPending: map['totalPending'] as int? ?? 0,
      );
}

// Response cho API approve student
class ApproveStudentResponse {
  final String message;
  final UserProfile approvedStudent;
  final ApproveStudentData data;

  const ApproveStudentResponse({
    required this.message,
    required this.approvedStudent,
    required this.data,
  });

  factory ApproveStudentResponse.fromMap(Map<String, dynamic> map) =>
      ApproveStudentResponse(
        message: map['message']?.toString() ?? '',
        approvedStudent: UserProfile.fromMap(
          map['approvedStudent'] as Map<String, dynamic>,
        ),
        data: ApproveStudentData.fromMap(map['data'] as Map<String, dynamic>),
      );

  static ApproveStudentResponse fromJson(String source) =>
      ApproveStudentResponse.fromMap(
        jsonDecode(source) as Map<String, dynamic>,
      );
}

// Model cho response đăng ký lớp học
class JoinClassData {
  final String classId;
  final String className;
  final String subject;
  final String teacherId;
  final String status;
  final DateTime registeredAt;
  final int position;

  const JoinClassData({
    required this.classId,
    required this.className,
    required this.subject,
    required this.teacherId,
    required this.status,
    required this.registeredAt,
    required this.position,
  });

  factory JoinClassData.fromMap(Map<String, dynamic> map) => JoinClassData(
    classId: map['classId']?.toString() ?? '',
    className: map['className']?.toString() ?? '',
    subject: map['subject']?.toString() ?? '',
    teacherId: map['teacherId']?.toString() ?? '',
    status: map['status']?.toString() ?? '',
    registeredAt: DateTime.parse(map['registeredAt']?.toString() ?? ''),
    position: map['position'] as int? ?? 0,
  );
}

// Response cho API đăng ký lớp học
class JoinClassResponse {
  final String message;
  final JoinClassData data;
  final bool success = true;
  final ClassModel? updatedClass;

  const JoinClassResponse({required this.message, required this.data, this.updatedClass});

  factory JoinClassResponse.fromMap(Map<String, dynamic> map) =>
      JoinClassResponse(
        message: map['message']?.toString() ?? '',
        data: JoinClassData.fromMap(map['data'] as Map<String, dynamic>),
        updatedClass: map['updatedClass'] != null 
            ? ClassModel.fromMap(map['updatedClass'] as Map<String, dynamic>) 
            : null,  // Nếu API join return 'updatedClass', dùng nó; otherwise từ repository
      );

  static JoinClassResponse fromJson(String source) =>
      JoinClassResponse.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
