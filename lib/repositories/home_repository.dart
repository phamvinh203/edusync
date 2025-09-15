import 'package:edusync/core/network/dio_api.dart';
import 'package:edusync/models/home_model.dart';
import 'package:edusync/models/exercise_model.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/repositories/exercise_repository.dart';
import 'package:edusync/repositories/class_repository.dart';

class DashboardRepository {
  final DioClient client;
  final ExerciseRepository _exerciseRepo;
  final ClassRepository _classRepo;

  DashboardRepository({
    DioClient? client,
    ExerciseRepository? exerciseRepo,
    ClassRepository? classRepo,
  }) : client = client ?? DioClient(),
       _exerciseRepo = exerciseRepo ?? ExerciseRepository(),
       _classRepo = classRepo ?? ClassRepository();

  /// Lấy dữ liệu dashboard cho học sinh
  Future<StudentDashboard> getStudentDashboard() async {
    try {
      // Parallel fetch các dữ liệu cần thiết
      final futures = await Future.wait([
        _getStudentClasses(),
        _getStudentExercises(),
        _getStudentSubmissions(),
      ]);

      final classes = futures[0] as List<ClassModel>;
      final exercises = futures[1] as List<Exercise>;
      final submittedExercises = futures[2] as List<Exercise>;

      // Tính toán các thống kê
      final todayAssignments = _getTodayAssignments(
        exercises,
        submittedExercises,
      );
      final recentActivities = _getStudentRecentActivities(
        exercises,
        submittedExercises,
        classes,
      );

      return StudentDashboard(
        todayAssignments: todayAssignments,
        totalClassesJoined: classes.length,
        recentActivities: recentActivities,
        pendingAssignments: _getPendingAssignmentsCount(
          exercises,
          submittedExercises,
        ),
        completedAssignments: submittedExercises.length,
      );
    } catch (e) {
      throw Exception('Không thể tải dữ liệu dashboard học sinh: $e');
    }
  }

  /// Lấy dữ liệu dashboard cho giáo viên
  Future<TeacherDashboard> getTeacherDashboard() async {
    try {
      // Parallel fetch các dữ liệu cần thiết
      final futures = await Future.wait([
        _getTeacherClasses(),
        _getTeacherExercises(),
        _getTodayTeacherSchedule(),
      ]);

      final classes = futures[0] as List<ClassModel>;
      final exercises = futures[1] as List<Exercise>;
      final todaySchedule = futures[2] as TodaySchedule;

      // Tính toán thống kê
      final totalStudents = _calculateTotalStudents(classes);
      final pendingGrading = _getPendingGradingStats(exercises);
      final recentActivities = _getTeacherRecentActivities(exercises, classes);

      return TeacherDashboard(
        classStats: TeacherClassStats(
          totalClasses: classes.length,
          totalStudents: totalStudents,
          classes: classes,
        ),
        gradingStats: pendingGrading,
        todaySchedule: todaySchedule,
        recentActivities: recentActivities,
      );
    } catch (e) {
      throw Exception('Không thể tải dữ liệu dashboard giáo viên: $e');
    }
  }

  // Helper methods cho student dashboard
  Future<List<ClassModel>> _getStudentClasses() async {
    return await _classRepo.getMyRegisteredClasses();
  }

  Future<List<Exercise>> _getStudentExercises() async {
    try {
      final classes = await _getStudentClasses();
      final allExercises = <Exercise>[];

      for (final classModel in classes) {
        if (classModel.id != null) {
          try {
            final exercises = await _exerciseRepo.getExercisesByClass(
              classModel.id!,
            );
            allExercises.addAll(exercises);
          } catch (e) {
            // Continue với các lớp khác nếu một lớp fail
            print('Error loading exercises for class ${classModel.id}: $e');
          }
        }
      }

      return allExercises;
    } catch (e) {
      return [];
    }
  }

  Future<List<Exercise>> _getStudentSubmissions() async {
    try {
      return await _exerciseRepo.getMySubmittedExercises();
    } catch (e) {
      return [];
    }
  }

  List<TodayAssignment> _getTodayAssignments(
    List<Exercise> exercises,
    List<Exercise> submittedExercises,
  ) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return exercises
        .where(
          (exercise) =>
              exercise.dueDate.isAfter(todayStart) &&
              exercise.dueDate.isBefore(todayEnd),
        )
        .map((exercise) {
          final isSubmitted = submittedExercises.any(
            (sub) => sub.id == exercise.id,
          );
          return TodayAssignment.fromExercise(
            exercise,
            isSubmitted: isSubmitted,
          );
        })
        .toList();
  }

  int _getPendingAssignmentsCount(
    List<Exercise> exercises,
    List<Exercise> submittedExercises,
  ) {
    final submittedIds = submittedExercises.map((e) => e.id).toSet();
    return exercises
        .where(
          (exercise) =>
              !submittedIds.contains(exercise.id) &&
              exercise.dueDate.isAfter(DateTime.now()),
        )
        .length;
  }

  List<RecentActivity> _getStudentRecentActivities(
    List<Exercise> exercises,
    List<Exercise> submittedExercises,
    List<ClassModel> classes,
  ) {
    final activities = <RecentActivity>[];
    final now = DateTime.now();

    // Thêm activities cho bài tập vừa nộp (3 ngày gần đây)
    for (final exercise in submittedExercises) {
      if (exercise.createdAt != null &&
          now.difference(exercise.createdAt!).inDays <= 3) {
        final className = _getClassNameById(exercise.classId.id, classes);
        activities.add(
          RecentActivity.fromSubmission(
            submission: Submission(
              id: exercise.id,
              submittedAt: exercise.createdAt,
            ),
            exerciseTitle: exercise.title,
            className: className,
          ),
        );
      }
    }

    // Thêm activities cho lớp học sắp diễn ra (trong 3 giờ tới)
    activities.addAll(_getUpcomingClassActivities(classes));

    // Thêm activities cho bài tập sắp hết hạn (trong 24 giờ tới)
    activities.addAll(
      _getDueAssignmentActivities(exercises, submittedExercises),
    );

    // Sắp xếp theo thời gian gần đây nhất
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities.take(10).toList(); // Chỉ lấy 10 activities gần nhất
  }

  // Helper methods cho teacher dashboard
  Future<List<ClassModel>> _getTeacherClasses() async {
    try {
      return await _classRepo.getAllClasses();
    } catch (e) {
      return [];
    }
  }

  Future<List<Exercise>> _getTeacherExercises() async {
    try {
      return await _exerciseRepo.getMyCreatedExercises();
    } catch (e) {
      return [];
    }
  }

  Future<TodaySchedule> _getTodayTeacherSchedule() async {
    try {
      final classes = await _getTeacherClasses();
      final today = DateTime.now();
      final todayWeekday = _getDayOfWeekString(today.weekday);

      final todayClasses = <TodayClass>[];

      for (final classModel in classes) {
        for (final schedule in classModel.schedule) {
          if (schedule.dayOfWeek.toLowerCase() == todayWeekday.toLowerCase()) {
            todayClasses.add(
              TodayClass(
                classId: classModel.id ?? '',
                className: classModel.nameClass,
                subject: classModel.subject,
                timeRange: '${schedule.startTime} - ${schedule.endTime}',
                location: classModel.location,
                studentCount: classModel.students.length,
              ),
            );
          }
        }
      }

      return TodaySchedule(
        classes: todayClasses,
        totalClassesToday: todayClasses.length,
      );
    } catch (e) {
      return const TodaySchedule(classes: [], totalClassesToday: 0);
    }
  }

  int _calculateTotalStudents(List<ClassModel> classes) {
    return classes.fold(
      0,
      (sum, classModel) => sum + classModel.students.length,
    );
  }

  PendingGradingStats _getPendingGradingStats(List<Exercise> exercises) {
    final needGrading =
        exercises
            .where((exercise) => (exercise.ungradedCount ?? 0) > 0)
            .toList();

    final totalPending = needGrading.fold(
      0,
      (sum, exercise) => sum + (exercise.ungradedCount ?? 0),
    );

    return PendingGradingStats(
      totalPendingGrading: totalPending,
      exercisesNeedGrading: needGrading,
    );
  }

  List<RecentActivity> _getTeacherRecentActivities(
    List<Exercise> exercises,
    List<ClassModel> classes,
  ) {
    final activities = <RecentActivity>[];
    final now = DateTime.now();

    // Thêm activities cho bài tập vừa tạo (3 ngày gần đây)
    for (final exercise in exercises) {
      if (exercise.createdAt != null &&
          now.difference(exercise.createdAt!).inDays <= 3) {
        activities.add(
          RecentActivity.fromCreatedExercise(
            exercise: exercise,
            submissionCount: exercise.submissionCount ?? 0,
          ),
        );
      }
    }

    // Thêm activities cho lớp học sắp tới
    activities.addAll(_getUpcomingClassActivities(classes));

    // Sắp xếp theo thời gian
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities.take(10).toList();
  }

  // Common helper methods
  String? _getClassNameById(String? classId, List<ClassModel> classes) {
    if (classId == null) return null;
    try {
      return classes.firstWhere((c) => c.id == classId).nameClass;
    } catch (e) {
      return null;
    }
  }

  List<RecentActivity> _getUpcomingClassActivities(List<ClassModel> classes) {
    final activities = <RecentActivity>[];
    final now = DateTime.now();
    final upcoming = now.add(const Duration(hours: 3));

    for (final classModel in classes) {
      for (final schedule in classModel.schedule) {
        final nextClass = _getNextClassTime(schedule, now);
        if (nextClass != null && nextClass.isBefore(upcoming)) {
          activities.add(
            RecentActivity.fromUpcomingClass(
              classModel: classModel,
              scheduleTime: nextClass,
              dayOfWeek: _getVietnameseDayName(schedule.dayOfWeek),
              timeRange: '${schedule.startTime} - ${schedule.endTime}',
            ),
          );
        }
      }
    }

    return activities;
  }

  List<RecentActivity> _getDueAssignmentActivities(
    List<Exercise> exercises,
    List<Exercise> submittedExercises,
  ) {
    final activities = <RecentActivity>[];
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final submittedIds = submittedExercises.map((e) => e.id).toSet();

    for (final exercise in exercises) {
      if (!submittedIds.contains(exercise.id) &&
          exercise.dueDate.isAfter(now) &&
          exercise.dueDate.isBefore(tomorrow)) {
        final hoursUntil = exercise.dueDate.difference(now).inHours;
        activities.add(
          RecentActivity.fromDueAssignment(
            exercise: exercise,
            hoursUntilDue: hoursUntil,
          ),
        );
      }
    }

    return activities;
  }

  DateTime? _getNextClassTime(Schedule schedule, DateTime from) {
    final weekdays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final targetWeekday =
        weekdays.indexOf(schedule.dayOfWeek.toLowerCase()) + 1;

    if (targetWeekday == 0) return null; // Invalid day

    final today = from;
    final todayWeekday = today.weekday;

    int daysUntilTarget = targetWeekday - todayWeekday;
    if (daysUntilTarget <= 0) {
      daysUntilTarget += 7; // Next week
    }

    final targetDate = today.add(Duration(days: daysUntilTarget));

    // Parse time (assuming format "HH:mm")
    final timeParts = schedule.startTime.split(':');
    if (timeParts.length != 2) return null;

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);

    if (hour == null || minute == null) return null;

    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
      minute,
    );
  }

  String _getDayOfWeekString(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  String _getVietnameseDayName(String englishDay) {
    const dayMap = {
      'Monday': 'Thứ 2',
      'Tuesday': 'Thứ 3',
      'Wednesday': 'Thứ 4',
      'Thursday': 'Thứ 5',
      'Friday': 'Thứ 6',
      'Saturday': 'Thứ 7',
      'Sunday': 'Chủ nhật',
    };
    return dayMap[englishDay] ?? englishDay;
  }
}
