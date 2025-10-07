import 'package:flutter/material.dart';
import 'package:edusync/core/services/notification_service.dart';
import 'package:edusync/core/services/notification_manager.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/models/exercise_model.dart';

/// Demo screen to test notification functionality
/// This can be used for testing the notification implementation
class NotificationTestScreen extends StatelessWidget {
  const NotificationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notifications'),
        backgroundColor: Colors.blue[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Teacher Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _testClassCreatedNotification(),
              child: const Text('Test Class Created Notification'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _testAssignmentCreatedNotification(),
              child: const Text('Test Assignment Created Notification'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Student Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _testClassRegistrationNotification(),
              child: const Text('Test Class Registration Notification'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _testNewAssignmentNotification(),
              child: const Text('Test New Assignment Notification'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _testClassReminderNotification(),
              child: const Text('Test Class Reminder Notification'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _testScheduledClassReminder(),
              child: const Text('Test Scheduled Class Reminder (30s)'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Utility',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _clearAllNotifications(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[300]),
              child: const Text('Clear All Notifications'),
            ),
          ],
        ),
      ),
    );
  }

  /// Test notification for successful class creation (Teacher)
  Future<void> _testClassCreatedNotification() async {
    await NotificationService().showClassCreatedNotification(
      className: 'Toán 12A1',
      subject: 'Toán học',
    );
  }

  /// Test notification for successful assignment creation (Teacher)
  Future<void> _testAssignmentCreatedNotification() async {
    await NotificationService().showAssignmentCreatedNotification(
      assignmentTitle: 'Bài tập về hàm số',
      className: 'Toán 12A1',
    );
  }

  /// Test notification for successful class registration (Student)
  Future<void> _testClassRegistrationNotification() async {
    await NotificationService().showClassRegistrationSuccessNotification(
      className: 'Toán 12A1',
      subject: 'Toán học',
    );
  }

  /// Test notification for new assignment (Student)
  Future<void> _testNewAssignmentNotification() async {
    await NotificationService().showNewAssignmentNotification(
      assignmentTitle: 'Bài tập về hàm số',
      className: 'Toán 12A1',
      teacherName: 'Thầy Nguyễn Văn A',
      dueDate: DateTime.now().add(const Duration(days: 7)),
    );
  }

  /// Test notification for class schedule reminder (Student)
  Future<void> _testClassReminderNotification() async {
    final classTime = DateTime.now().add(const Duration(minutes: 15));
    await NotificationService().showClassScheduleNotification(
      className: 'Toán 12A1',
      subject: 'Toán học',
      location: 'Phòng A101',
      classTime: classTime,
    );
  }

  /// Test scheduled class reminder (30 seconds from now)
  Future<void> _testScheduledClassReminder() async {
    final classTime = DateTime.now().add(const Duration(minutes: 1));
    await NotificationService().scheduleClassReminder(
      className: 'Toán 12A1',
      subject: 'Toán học',
      location: 'Phòng A101',
      classTime: classTime,
      minutesBefore: 0, // Show notification immediately when classTime arrives
    );
  }

  /// Clear all notifications
  Future<void> _clearAllNotifications() async {
    await NotificationService().clearAllNotifications();
  }
}

/// Example usage in a real app:
/// 
/// 1. Teacher creates a class:
/// ```dart
/// // In your class creation success handler
/// await NotificationService().showClassCreatedNotification(
///   className: createdClass.nameClass,
///   subject: createdClass.subject,
/// );
/// ```
/// 
/// 2. Teacher creates an assignment:
/// ```dart
/// // In your exercise creation success handler
/// await NotificationService().showAssignmentCreatedNotification(
///   assignmentTitle: exercise.title,
///   className: className,
/// );
/// // Also notify students
/// await NotificationManager().notifyStudentsAboutNewAssignment(
///   classId: classId,
///   exercise: exercise,
///   teacherName: teacherName,
/// );
/// ```
/// 
/// 3. Student registers for a class:
/// ```dart
/// // In your class join success handler
/// await NotificationService().showClassRegistrationSuccessNotification(
///   className: joinResponse.data.className,
///   subject: joinResponse.data.subject,
/// );
/// ```
/// 
/// 4. Schedule class reminders:
/// ```dart
/// // When student logs in or class schedule is updated
/// await NotificationManager().scheduleTodaysClassReminders();
/// ```