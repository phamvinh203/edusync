import 'package:edusync/core/services/notification_service.dart';
import 'package:edusync/core/services/user_session_service.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/models/exercise_model.dart';
import 'package:edusync/repositories/class_repository.dart';
import 'package:edusync/repositories/exercise_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced notification manager that handles complex notification scenarios
/// like notifying all students in a class, scheduling class reminders, etc.
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final NotificationService _notificationService = NotificationService();
  final ClassRepository _classRepository = ClassRepository();
  final ExerciseRepository _exerciseRepository = ExerciseRepository();

  /// Initialize the notification manager
  Future<void> init() async {
    await _notificationService.init();
    await _scheduleExistingClassReminders();
  }

  /// Student-side sync: detect new assignments across registered classes and
  /// show local notifications for any unseen exercises.
  Future<void> checkForNewAssignmentsForStudent() async {
    try {
      final role = await _getCurrentUserRole();
      if (role?.toLowerCase() != 'student') return;

      // Get the classes the current student is approved in
      final classes = await _classRepository.getMyRegisteredClasses();
      if (classes.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();

      for (final c in classes) {
        final classId = c.id;
        if (classId == null || classId.isEmpty) continue;

        // Fetch exercises for this class
        final exercises = await _exerciseRepository.getExercisesByClass(
          classId,
        );

        // Initialize seen set on first run to avoid spamming the user
        final initializedKey = _seenInitKey(classId);
        final isInitialized = prefs.getBool(initializedKey) ?? false;
        final seen =
            (prefs.getStringList(_seenIdsKey(classId)) ?? <String>[]).toSet();

        if (!isInitialized) {
          // Mark current items as seen; next runs will only notify truly new ones
          seen.addAll(exercises.map((e) => e.id).whereType<String>());
          await prefs.setStringList(_seenIdsKey(classId), seen.toList());
          await prefs.setBool(initializedKey, true);
          continue;
        }

        // Find unseen exercises (new ones)
        final List<Exercise> newOnes = [];
        for (final ex in exercises) {
          final exId = ex.id;
          if (exId == null || exId.isEmpty) continue;
          if (!seen.contains(exId)) {
            newOnes.add(ex);
            seen.add(exId);
          }
        }

        // Notify for unseen exercises
        for (final ex in newOnes) {
          final className = ex.classId.nameClass ?? c.nameClass;
          final teacherName =
              ex.createdBy.username ?? ex.createdBy.email ?? 'Giáo viên';
          await _notificationService.showNewAssignmentNotification(
            assignmentTitle: ex.title,
            className: className,
            teacherName: teacherName,
            dueDate: ex.dueDate,
          );
        }

        // Persist updated seen set
        await prefs.setStringList(_seenIdsKey(classId), seen.toList());
      }
    } catch (e) {
      print('Error checking new assignments: $e');
    }
  }

  String _seenIdsKey(String classId) => 'seen_exercise_ids_$classId';
  String _seenInitKey(String classId) => 'seen_exercise_ids_inited_$classId';

  /// Notify all students in a class about a new assignment
  Future<void> notifyStudentsAboutNewAssignment({
    required String classId,
    required Exercise exercise,
    required String teacherName,
  }) async {
    try {
      // For local notifications, we can only notify the current user
      // In a real app, you'd send push notifications through a backend service

      // Check if current user is a student in this class
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) return;

      final userRole = await _getCurrentUserRole();
      if (userRole != 'student') return;

      // Check if user is registered in this class
      final isInClass = await _isUserInClass(currentUserId, classId);
      if (!isInClass) return;

      // Get class details
      final classDetails = await _getClassDetails(classId);

      await _notificationService.showNewAssignmentNotification(
        assignmentTitle: exercise.title,
        className: classDetails?.nameClass ?? 'Lớp học',
        teacherName: teacherName,
        dueDate: exercise.dueDate,
      );
    } catch (e) {
      print('Error notifying students about new assignment: $e');
    }
  }

  /// Schedule notifications for class schedule
  Future<void> scheduleClassNotifications({
    required ClassModel classInfo,
    List<DateTime>? specificDates,
  }) async {
    try {
      // Parse the schedule list to get class times
      final classTimes = _parseClassScheduleFromList(
        classInfo.schedule,
        specificDates,
      );

      for (final classTime in classTimes) {
        await _notificationService.scheduleClassReminder(
          className: classInfo.nameClass,
          subject: classInfo.subject,
          location: classInfo.location ?? 'Phòng học',
          classTime: classTime,
          minutesBefore: 15, // Notify 15 minutes before
        );
      }
    } catch (e) {
      print('Error scheduling class notifications: $e');
    }
  }

  /// Schedule daily class reminders for today's classes
  Future<void> scheduleTodaysClassReminders() async {
    try {
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) return;

      // Get user's registered classes
      final registeredClasses = await _classRepository.getMyRegisteredClasses();

      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      for (final classInfo in registeredClasses) {
        // Parse today's schedule for this class
        final todaysClasses =
            _parseClassScheduleFromList(classInfo.schedule, [today])
                .where(
                  (time) =>
                      time.isAfter(todayStart) &&
                      time.isBefore(todayEnd) &&
                      time.isAfter(DateTime.now()), // Only future classes
                )
                .toList();

        for (final classTime in todaysClasses) {
          await _notificationService.scheduleClassReminder(
            className: classInfo.nameClass,
            subject: classInfo.subject,
            location: classInfo.location ?? 'Phòng học',
            classTime: classTime,
            minutesBefore: 15,
          );
        }
      }
    } catch (e) {
      print('Error scheduling today\'s class reminders: $e');
    }
  }

  /// Auto-schedule class reminders for the next week
  Future<void> _scheduleExistingClassReminders() async {
    try {
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) return;

      final userRole = await _getCurrentUserRole();
      if (userRole != 'student') return;

      // Get user's registered classes
      final registeredClasses = await _classRepository.getMyRegisteredClasses();

      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      for (final classInfo in registeredClasses) {
        // Generate class times for the next week
        final weeklySchedule = _generateWeeklyScheduleFromList(
          classInfo.schedule,
          now,
          nextWeek,
        );

        for (final classTime in weeklySchedule) {
          await _notificationService.scheduleClassReminder(
            className: classInfo.nameClass,
            subject: classInfo.subject,
            location: classInfo.location ?? 'Phòng học',
            classTime: classTime,
            minutesBefore: 15,
          );
        }
      }
    } catch (e) {
      print('Error auto-scheduling class reminders: $e');
    }
  }

  /// Parse class schedule from List<Schedule> and return list of DateTime objects
  List<DateTime> _parseClassScheduleFromList(
    List<Schedule> schedules,
    List<DateTime>? dates,
  ) {
    final List<DateTime> classTimes = [];

    if (schedules.isEmpty) return classTimes;

    try {
      final now = DateTime.now();
      final targetDates = dates ?? [now];

      for (final date in targetDates) {
        for (final schedule in schedules) {
          // Parse start time (format: "08:00")
          final timeParts = schedule.startTime.split(':');
          if (timeParts.length == 2) {
            final hour = int.tryParse(timeParts[0]);
            final minute = int.tryParse(timeParts[1]);

            if (hour != null && minute != null) {
              // Check if this day matches the schedule day
              if (_isDayMatch(date, schedule.dayOfWeek)) {
                final classTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  hour,
                  minute,
                );

                if (classTime.isAfter(DateTime.now())) {
                  classTimes.add(classTime);
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error parsing schedule: $e');
    }

    return classTimes;
  }

  /// Check if the given date matches the schedule day of week
  bool _isDayMatch(DateTime date, String dayOfWeek) {
    final weekdayMap = {
      'monday': 1,
      'thứ 2': 1,
      'thu 2': 1,
      'tuesday': 2,
      'thứ 3': 2,
      'thu 3': 2,
      'wednesday': 3,
      'thứ 4': 3,
      'thu 4': 3,
      'thursday': 4,
      'thứ 5': 4,
      'thu 5': 4,
      'friday': 5,
      'thứ 6': 5,
      'thu 6': 5,
      'saturday': 6,
      'thứ 7': 6,
      'thu 7': 6,
      'sunday': 7,
      'chủ nhật': 7,
      'chu nhat': 7,
    };

    final normalizedDay = dayOfWeek.toLowerCase();
    final expectedWeekday = weekdayMap[normalizedDay];

    return expectedWeekday != null && date.weekday == expectedWeekday;
  }

  /// Generate weekly schedule for class reminders from List<Schedule>
  List<DateTime> _generateWeeklyScheduleFromList(
    List<Schedule> schedules,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Generate dates for each day in the range
    final dates = <DateTime>[];
    var currentDate = startDate;

    while (currentDate.isBefore(endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return _parseClassScheduleFromList(schedules, dates);
  }

  /// Get current user ID from storage
  Future<String?> _getCurrentUserId() async {
    return await UserSessionService.getUserId();
  }

  /// Get current user role from storage
  Future<String?> _getCurrentUserRole() async {
    return await UserSessionService.getUserRole();
  }

  /// Check if user is registered in a specific class
  Future<bool> _isUserInClass(String userId, String classId) async {
    try {
      final registeredClasses = await _classRepository.getMyRegisteredClasses();
      return registeredClasses.any((c) => c.id == classId);
    } catch (e) {
      return false;
    }
  }

  /// Get class details by ID
  Future<ClassModel?> _getClassDetails(String classId) async {
    try {
      final allClasses = await _classRepository.getAllClasses();
      return allClasses.firstWhere(
        (c) => c.id == classId,
        orElse: () => throw Exception('Class not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Clear all scheduled class notifications
  Future<void> clearAllClassNotifications() async {
    await _notificationService.clearAllNotifications();
  }

  /// Update notification settings
  Future<void> updateNotificationSettings({
    bool? classReminders,
    bool? assignmentNotifications,
    int? reminderMinutes,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (classReminders != null) {
      await prefs.setBool('class_reminders_enabled', classReminders);
    }

    if (assignmentNotifications != null) {
      await prefs.setBool(
        'assignment_notifications_enabled',
        assignmentNotifications,
      );
    }

    if (reminderMinutes != null) {
      await prefs.setInt('reminder_minutes', reminderMinutes);
    }
  }

  /// Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'class_reminders_enabled':
          prefs.getBool('class_reminders_enabled') ?? true,
      'assignment_notifications_enabled':
          prefs.getBool('assignment_notifications_enabled') ?? true,
      'reminder_minutes': prefs.getInt('reminder_minutes') ?? 15,
    };
  }
}
