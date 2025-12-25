import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> init() async {
    if (_isInitialized) return;

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Combined initialization
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    if (Platform.isAndroid) {
      await _requestAndroidPermissions();
    }

    _isInitialized = true;
  }

  /// Request Android notification permissions (Android 13+)
  Future<void> _requestAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestNotificationsPermission();
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    debugPrint('Notification tapped: ${notificationResponse.payload}');
    // Handle navigation based on payload if needed
  }

  /// Show a basic notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'edusync_default',
    String channelName = 'EduSync Notifications',
    String channelDescription = 'General notifications from EduSync',
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    if (!_isInitialized) await init();

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: importance,
          priority: priority,
          ticker: 'ticker',
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Schedule a notification for a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    String channelId = 'edusync_scheduled',
    String channelName = 'EduSync Scheduled',
    String channelDescription = 'Scheduled notifications from EduSync',
  }) async {
    if (!_isInitialized) await init();

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledTime),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Convert DateTime to TZDateTime (timezone aware)
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    // Initialize timezone data if not already done
    tz.initializeTimeZones();
    final location = tz.getLocation('Asia/Ho_Chi_Minh');
    return tz.TZDateTime.from(dateTime, location);
  }

  /// Teacher Notifications

  /// Show notification when class is created successfully
  Future<void> showClassCreatedNotification({
    required String className,
    required String subject,
  }) async {
    await showNotification(
      id: _generateId('class_created'),
      title: '🎉 Tạo lớp thành công!',
      body: 'Lớp "$className" môn $subject đã được tạo thành công.',
      channelId: 'teacher_actions',
      channelName: 'Hoạt động giáo viên',
      channelDescription: 'Thông báo về các hoạt động của giáo viên',
      payload: 'class_created:$className',
    );
  }

  /// Show notification when assignment is created successfully
  Future<void> showAssignmentCreatedNotification({
    required String assignmentTitle,
    required String className,
  }) async {
    await showNotification(
      id: _generateId('assignment_created'),
      title: '📝 Tạo bài tập thành công!',
      body: 'Bài tập "$assignmentTitle" cho lớp $className đã được tạo.',
      channelId: 'teacher_actions',
      channelName: 'Hoạt động giáo viên',
      channelDescription: 'Thông báo về các hoạt động của giáo viên',
      payload: 'assignment_created:$assignmentTitle',
    );
  }

  /// Student Notifications

  /// Show notification when successfully registered for a class
  Future<void> showClassRegistrationSuccessNotification({
    required String className,
    required String subject,
  }) async {
    await showNotification(
      id: _generateId('class_registered'),
      title: '✅ Đăng ký lớp thành công!',
      body: 'Bạn đã đăng ký thành công lớp "$className" môn $subject.',
      channelId: 'student_actions',
      channelName: 'Hoạt động học sinh',
      channelDescription: 'Thông báo về các hoạt động của học sinh',
      payload: 'class_registered:$className',
    );
  }

  /// Show notification when new assignment is assigned to student's class
  Future<void> showNewAssignmentNotification({
    required String assignmentTitle,
    required String className,
    required String teacherName,
    DateTime? dueDate,
  }) async {
    String body =
        'Giáo viên $teacherName đã giao bài tập "$assignmentTitle" cho lớp $className.';
    if (dueDate != null) {
      body += ' Hạn nộp: ${_formatDateTime(dueDate)}';
    }

    await showNotification(
      id: _generateId('new_assignment'),
      title: '📚 Bài tập mới được giao!',
      body: body,
      channelId: 'assignments',
      channelName: 'Bài tập',
      channelDescription: 'Thông báo về bài tập mới',
      payload: 'new_assignment:$assignmentTitle',
    );
  }

  /// Show notification for class schedule reminder
  Future<void> showClassScheduleNotification({
    required String className,
    required String subject,
    required String location,
    required DateTime classTime,
  }) async {
    await showNotification(
      id: _generateId('class_schedule'),
      title: '🕒 Nhắc nhở lịch học!',
      body:
          'Lớp "$className" môn $subject sẽ bắt đầu lúc ${_formatTime(classTime)} tại $location.',
      channelId: 'schedule',
      channelName: 'Lịch học',
      channelDescription: 'Thông báo nhắc nhở lịch học',
      payload: 'class_schedule:$className',
    );
  }

  /// Schedule class reminder notifications
  Future<void> scheduleClassReminder({
    required String className,
    required String subject,
    required String location,
    required DateTime classTime,
    int minutesBefore = 15, // Remind 15 minutes before
  }) async {
    final reminderTime = classTime.subtract(Duration(minutes: minutesBefore));

    // Only schedule if the reminder time is in the future
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: _generateId('class_reminder_${classTime.millisecondsSinceEpoch}'),
        title: '⏰ Lịch học sắp bắt đầu!',
        body:
            'Lớp "$className" môn $subject sẽ bắt đầu sau $minutesBefore phút tại $location.',
        scheduledTime: reminderTime,
        channelId: 'schedule_reminders',
        channelName: 'Nhắc nhở lịch học',
        channelDescription: 'Thông báo nhắc nhở trước giờ học',
        payload:
            'class_reminder:$className:${classTime.millisecondsSinceEpoch}',
      );
    }
  }

  /// Utility Methods

  /// Generate unique notification ID based on type and content
  int _generateId(String type) {
    return '${type}_${DateTime.now().millisecondsSinceEpoch}'.hashCode.abs();
  }

  /// Format DateTime for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
  }

  /// Format time for display
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Clear specific notification
  Future<void> clearNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    return true; // iOS handles permissions differently
  }

  /// Save notification preference
  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  /// Get notification preference
  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }
}
