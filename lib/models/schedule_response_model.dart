class ScheduleResponseModel {
  final String message;
  final List<ClassSchedule> data;
  final int totalClasses;
  final String userRole;
  final ScheduleSummary summary;

  ScheduleResponseModel({
    required this.message,
    required this.data,
    required this.totalClasses,
    required this.userRole,
    required this.summary,
  });

  factory ScheduleResponseModel.fromJson(Map<String, dynamic> json) {
    return ScheduleResponseModel(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => ClassSchedule.fromJson(item))
          .toList(),
      totalClasses: json['totalClasses'] ?? 0,
      userRole: json['userRole'] ?? '',
      summary: ScheduleSummary.fromJson(json['summary'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
      'totalClasses': totalClasses,
      'userRole': userRole,
      'summary': summary.toJson(),
    };
  }
}

class ClassSchedule {
  final String classId;
  final String nameClass;
  final String subject;
  final String gradeLevel;
  final int pricePerSession;
  final String location;
  final Teacher teacher;
  final List<Schedule> schedule;
  final DateTime createdAt;

  ClassSchedule({
    required this.classId,
    required this.nameClass,
    required this.subject,
    required this.gradeLevel,
    required this.pricePerSession,
    required this.location,
    required this.teacher,
    required this.schedule,
    required this.createdAt,
  });

  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    return ClassSchedule(
      classId: json['classId'] ?? '',
      nameClass: json['nameClass'] ?? '',
      subject: json['subject'] ?? '',
      gradeLevel: json['gradeLevel'] ?? '',
      pricePerSession: json['pricePerSession'] ?? 0,
      location: json['location'] ?? '',
      teacher: Teacher.fromJson(json['teacher'] ?? {}),
      schedule: (json['schedule'] as List<dynamic>? ?? [])
          .map((item) => Schedule.fromJson(item))
          .toList(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'nameClass': nameClass,
      'subject': subject,
      'gradeLevel': gradeLevel,
      'pricePerSession': pricePerSession,
      'location': location,
      'teacher': teacher.toJson(),
      'schedule': schedule.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Teacher {
  final String id;
  final String email;
  final String username;

  Teacher({required this.id, required this.email, required this.username});

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'email': email, 'username': username};
  }
}

class Schedule {
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String duration;
  final int durationInMinutes;

  Schedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.durationInMinutes,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      dayOfWeek: json['dayOfWeek'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      duration: json['duration'] ?? '',
      durationInMinutes: json['durationInMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'durationInMinutes': durationInMinutes,
    };
  }
}

class ScheduleSummary {
  final int totalClassesWithSchedule;
  final DateTime retrievedAt;
  final String accessLevel;

  ScheduleSummary({
    required this.totalClassesWithSchedule,
    required this.retrievedAt,
    required this.accessLevel,
  });

  factory ScheduleSummary.fromJson(Map<String, dynamic> json) {
    return ScheduleSummary(
      totalClassesWithSchedule: json['totalClassesWithSchedule'] ?? 0,
      retrievedAt: json['retrievedAt'] != null 
          ? DateTime.parse(json['retrievedAt']) 
          : DateTime.now(),
      accessLevel: json['accessLevel'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalClassesWithSchedule': totalClassesWithSchedule,
      'retrievedAt': retrievedAt.toIso8601String(),
      'accessLevel': accessLevel,
    };
  }
}
