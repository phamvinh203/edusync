import 'dart:convert';
import 'package:edusync/models/exercise_model.dart';
import 'package:flutter/widgets.dart';
import 'package:edusync/l10n/app_localizations.dart';
import 'package:edusync/models/class_model.dart';

// Model cho bài tập hôm nay
class TodayAssignment {
  final String id;
  final String title;
  final String type;
  final DateTime dueDate;
  final String? classId;
  final String? className;
  final String? subject;
  final bool isSubmitted;
  final bool isLate;
  final bool isOverdue;

  const TodayAssignment({
    required this.id,
    required this.title,
    required this.type,
    required this.dueDate,
    this.classId,
    this.className,
    this.subject,
    this.isSubmitted = false,
    this.isLate = false,
    this.isOverdue = false,
  });

  factory TodayAssignment.fromExercise(
    Exercise exercise, {
    bool isSubmitted = false,
  }) {
    final now = DateTime.now();
    final isOverdue = now.isAfter(exercise.dueDate);

    return TodayAssignment(
      id: exercise.id ?? '',
      title: exercise.title,
      type: exercise.type,
      dueDate: exercise.dueDate,
      classId: exercise.classId.id,
      className: exercise.classId.nameClass,
      subject: exercise.subject,
      isSubmitted: isSubmitted,
      isLate: false, // Will be calculated based on submission time
      isOverdue: isOverdue,
    );
  }
}

// Model cho hoạt động gần đây
class RecentActivity {
  final String id;
  final String
  type; // 'submission', 'exercise_created', 'class_schedule', 'assignment_due'
  final String title;
  final String description;
  final DateTime timestamp;
  final String? classId;
  final String? className;
  final String? exerciseId;
  final Map<String, dynamic>? metadata; // Additional data

  const RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.classId,
    this.className,
    this.exerciseId,
    this.metadata,
  });

  factory RecentActivity.fromSubmission({
    required Submission submission,
    required String exerciseTitle,
    required String? className,
    BuildContext? context,
  }) {
    final loc = context != null ? AppLocalizations.of(context) : null;
    final title = loc != null ? loc.submission : 'Submission';
    final descriptionPrefix = loc != null ? loc.submissionContent : 'Submitted';
    final description =
        '$descriptionPrefix "$exerciseTitle"${className != null ? ' - $className' : ''}';

    return RecentActivity(
      id: submission.id ?? '',
      type: 'submission',
      title: title,
      description: description,
      timestamp: submission.submittedAt ?? DateTime.now(),
      exerciseId: submission.id,
      className: className,
      metadata: {
        'grade': submission.grade,
        'hasGrade': submission.hasGrade,
        'isLate': submission.isLate,
        'exerciseTitle': exerciseTitle,
        'className': className,
      },
    );
  }

  factory RecentActivity.fromUpcomingClass({
    required ClassModel classModel,
    required DateTime scheduleTime,
    required String dayOfWeek,
    required String timeRange,
    BuildContext? context,
  }) {
    final loc = context != null ? AppLocalizations.of(context) : null;
    final title = loc != null ? loc.upcomingClassTitle : 'Upcoming class';
    final description = '${classModel.nameClass} - $dayOfWeek $timeRange';

    return RecentActivity(
      id: '${classModel.id}_${scheduleTime.millisecondsSinceEpoch}',
      type: 'class_schedule',
      title: title,
      description: description,
      timestamp: scheduleTime,
      classId: classModel.id,
      className: classModel.nameClass,
      metadata: {
        'subject': classModel.subject,
        'location': classModel.location,
        'teacherName': classModel.teacherName,
        'timeRange': timeRange,
        'dayOfWeek': dayOfWeek,
      },
    );
  }

  factory RecentActivity.fromDueAssignment({
    required Exercise exercise,
    required int hoursUntilDue,
    BuildContext? context,
  }) {
    final loc = context != null ? AppLocalizations.of(context) : null;
    final title = loc != null ? loc.assignmentDueTitle : 'Assignment due';
    final description = loc != null
        ? loc.assignmentDueDescription(exercise.title, hoursUntilDue.toString())
        : '${exercise.title} - due in $hoursUntilDue hours';

    return RecentActivity(
      id: '${exercise.id}_due',
      type: 'assignment_due',
      title: title,
      description: description,
      timestamp: exercise.dueDate,
      classId: exercise.classId.id,
      className: exercise.classId.nameClass,
      exerciseId: exercise.id,
      metadata: {
        'subject': exercise.subject,
        'type': exercise.type,
        'maxScore': exercise.maxScore,
        'hoursUntilDue': hoursUntilDue,
      },
    );
  }

  factory RecentActivity.fromCreatedExercise({
    required Exercise exercise,
    required int submissionCount,
    BuildContext? context,
  }) {
    final loc = context != null ? AppLocalizations.of(context) : null;
    final title = loc != null ? loc.newExerciseCreatedTitle : 'New exercise created';
    final description = loc != null
        ? loc.newExerciseCreatedDescription(exercise.title, submissionCount.toString())
        : '${exercise.title} - $submissionCount students submitted';

    return RecentActivity(
      id: '${exercise.id}_created',
      type: 'exercise_created',
      title: title,
      description: description,
      timestamp: exercise.createdAt ?? DateTime.now(),
      classId: exercise.classId.id,
      className: exercise.classId.nameClass,
      exerciseId: exercise.id,
      metadata: {
        'subject': exercise.subject,
        'submissionCount': submissionCount,
        'exerciseTitle': exercise.title,
        'totalStudents':
            exercise.classId.id != null ? 0 : 0, // Will be populated
        'dueDate': exercise.dueDate.toIso8601String(),
      },
    );
  }
}

// Model cho thống kê lớp học của teacher
class TeacherClassStats {
  final int totalClasses;
  final int totalStudents;
  final List<ClassModel> classes;

  const TeacherClassStats({
    required this.totalClasses,
    required this.totalStudents,
    required this.classes,
  });
}

// Model cho thống kê bài tập chờ chấm của teacher
class PendingGradingStats {
  final int totalPendingGrading;
  final List<Exercise> exercisesNeedGrading;

  const PendingGradingStats({
    required this.totalPendingGrading,
    required this.exercisesNeedGrading,
  });
}

// Model cho lịch hôm nay của teacher
class TodaySchedule {
  final List<TodayClass> classes;
  final int totalClassesToday;

  const TodaySchedule({required this.classes, required this.totalClassesToday});
}

class TodayClass {
  final String classId;
  final String className;
  final String subject;
  final String timeRange;
  final String? location;
  final int studentCount;

  const TodayClass({
    required this.classId,
    required this.className,
    required this.subject,
    required this.timeRange,
    this.location,
    required this.studentCount,
  });
}

// Model tổng hợp cho dashboard của student
class StudentDashboard {
  final List<TodayAssignment> todayAssignments;
  final int totalClassesJoined;
  final List<RecentActivity> recentActivities;
  final int pendingAssignments;
  final int completedAssignments;

  const StudentDashboard({
    required this.todayAssignments,
    required this.totalClassesJoined,
    required this.recentActivities,
    required this.pendingAssignments,
    required this.completedAssignments,
  });

  factory StudentDashboard.fromMap(Map<String, dynamic> map) {
    return StudentDashboard(
      todayAssignments:
          (map['todayAssignments'] as List<dynamic>? ?? [])
              .map(
                (e) => TodayAssignment.fromExercise(
                  Exercise.fromMap(e['exercise'] as Map<String, dynamic>),
                  isSubmitted: e['isSubmitted'] ?? false,
                ),
              )
              .toList(),
      totalClassesJoined: map['totalClassesJoined'] ?? 0,
      recentActivities:
          (map['recentActivities'] as List<dynamic>? ?? [])
              .map(
                (e) => RecentActivity(
                  id: e['id'] ?? '',
                  type: e['type'] ?? '',
                  title: e['title'] ?? '',
                  description: e['description'] ?? '',
                  timestamp:
                      DateTime.tryParse(e['timestamp']?.toString() ?? '') ??
                      DateTime.now(),
                  classId: e['classId'],
                  className: e['className'],
                  exerciseId: e['exerciseId'],
                  metadata: e['metadata'],
                ),
              )
              .toList(),
      pendingAssignments: map['pendingAssignments'] ?? 0,
      completedAssignments: map['completedAssignments'] ?? 0,
    );
  }
}

// Model tổng hợp cho dashboard của teacher
class TeacherDashboard {
  final TeacherClassStats classStats;
  final PendingGradingStats gradingStats;
  final TodaySchedule todaySchedule;
  final List<RecentActivity> recentActivities;

  const TeacherDashboard({
    required this.classStats,
    required this.gradingStats,
    required this.todaySchedule,
    required this.recentActivities,
  });

  factory TeacherDashboard.fromMap(Map<String, dynamic> map) {
    return TeacherDashboard(
      classStats: TeacherClassStats(
        totalClasses: map['classStats']?['totalClasses'] ?? 0,
        totalStudents: map['classStats']?['totalStudents'] ?? 0,
        classes:
            (map['classStats']?['classes'] as List<dynamic>? ?? [])
                .map((e) => ClassModel.fromMap(e as Map<String, dynamic>))
                .toList(),
      ),
      gradingStats: PendingGradingStats(
        totalPendingGrading: map['gradingStats']?['totalPendingGrading'] ?? 0,
        exercisesNeedGrading:
            (map['gradingStats']?['exercisesNeedGrading'] as List<dynamic>? ??
                    [])
                .map((e) => Exercise.fromMap(e as Map<String, dynamic>))
                .toList(),
      ),
      todaySchedule: TodaySchedule(
        totalClassesToday: map['todaySchedule']?['totalClassesToday'] ?? 0,
        classes:
            (map['todaySchedule']?['classes'] as List<dynamic>? ?? [])
                .map(
                  (e) => TodayClass(
                    classId: e['classId'] ?? '',
                    className: e['className'] ?? '',
                    subject: e['subject'] ?? '',
                    timeRange: e['timeRange'] ?? '',
                    location: e['location'],
                    studentCount: e['studentCount'] ?? 0,
                  ),
                )
                .toList(),
      ),
      recentActivities:
          (map['recentActivities'] as List<dynamic>? ?? [])
              .map(
                (e) => RecentActivity(
                  id: e['id'] ?? '',
                  type: e['type'] ?? '',
                  title: e['title'] ?? '',
                  description: e['description'] ?? '',
                  timestamp:
                      DateTime.tryParse(e['timestamp']?.toString() ?? '') ??
                      DateTime.now(),
                  classId: e['classId'],
                  className: e['className'],
                  exerciseId: e['exerciseId'],
                  metadata: e['metadata'],
                ),
              )
              .toList(),
    );
  }
}

// Response models
class StudentDashboardResponse {
  final bool success;
  final String message;
  final StudentDashboard data;

  const StudentDashboardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StudentDashboardResponse.fromMap(Map<String, dynamic> map) {
    return StudentDashboardResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: StudentDashboard.fromMap(map['data'] ?? {}),
    );
  }

  static StudentDashboardResponse fromJson(String source) =>
      StudentDashboardResponse.fromMap(
        jsonDecode(source) as Map<String, dynamic>,
      );
}

class TeacherDashboardResponse {
  final bool success;
  final String message;
  final TeacherDashboard data;

  const TeacherDashboardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TeacherDashboardResponse.fromMap(Map<String, dynamic> map) {
    return TeacherDashboardResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: TeacherDashboard.fromMap(map['data'] ?? {}),
    );
  }

  static TeacherDashboardResponse fromJson(String source) =>
      TeacherDashboardResponse.fromMap(
        jsonDecode(source) as Map<String, dynamic>,
      );
}
