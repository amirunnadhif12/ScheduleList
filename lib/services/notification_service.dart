import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    debugPrint('✅ NotificationService initialized');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permission (Android 13+)
  Future<bool> requestPermission() async {
    final notifStatus = await Permission.notification.request();
    final alarmStatus = await Permission.scheduleExactAlarm.request();
    
    debugPrint('Notification permission: $notifStatus');
    debugPrint('Exact alarm permission: $alarmStatus');
    
    return notifStatus.isGranted;
  }

  /// Check if notifications are enabled
  Future<bool> isPermissionGranted() async {
    return await Permission.notification.isGranted;
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'schedule_list_channel',
      'Schedule List Notifications',
      channelDescription: 'Notifications for tasks and schedules',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification for a specific date and time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Don't schedule if the date is in the past
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('⚠️ Cannot schedule notification in the past');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'schedule_list_channel',
      'Schedule List Notifications',
      channelDescription: 'Notifications for tasks and schedules',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    debugPrint('📅 Notification scheduled for: $scheduledDate');
  }

  /// Schedule notification for a task deadline
  Future<void> scheduleTaskReminder({
    required int taskId,
    required String taskName,
    required DateTime deadline,
    String? description,
  }) async {
    // Notification 1 hour before deadline
    final oneHourBefore = deadline.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: taskId * 10 + 1,
        title: '⏰ Pengingat Tugas',
        body: '$taskName akan deadline dalam 1 jam lagi!',
        scheduledDate: oneHourBefore,
        payload: 'task_$taskId',
      );
    }

    // Notification at deadline
    if (deadline.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: taskId * 10 + 2,
        title: '🚨 Deadline Tugas!',
        body: '$taskName sudah mencapai deadline!',
        scheduledDate: deadline,
        payload: 'task_$taskId',
      );
    }

    // Notification 1 day before deadline
    final oneDayBefore = deadline.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: taskId * 10 + 3,
        title: '📋 Pengingat Tugas',
        body: '$taskName akan deadline besok!',
        scheduledDate: oneDayBefore,
        payload: 'task_$taskId',
      );
    }
  }

  /// Schedule notification for a schedule/event
  Future<void> scheduleEventReminder({
    required int scheduleId,
    required String scheduleName,
    required DateTime startTime,
    String? description,
  }) async {
    // Notification 30 minutes before
    final thirtyMinBefore = startTime.subtract(const Duration(minutes: 30));
    if (thirtyMinBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: scheduleId * 10 + 1,
        title: '📅 Jadwal Akan Dimulai',
        body: '$scheduleName akan dimulai dalam 30 menit',
        scheduledDate: thirtyMinBefore,
        payload: 'schedule_$scheduleId',
      );
    }

    // Notification at start time
    if (startTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: scheduleId * 10 + 2,
        title: '🔔 Jadwal Dimulai!',
        body: '$scheduleName dimulai sekarang!',
        scheduledDate: startTime,
        payload: 'schedule_$scheduleId',
      );
    }
  }

  /// Cancel all notifications for a task
  Future<void> cancelTaskReminders(int taskId) async {
    await _notifications.cancel(taskId * 10 + 1);
    await _notifications.cancel(taskId * 10 + 2);
    await _notifications.cancel(taskId * 10 + 3);
    debugPrint('❌ All reminders for task $taskId cancelled');
  }

  /// Cancel all notifications for a schedule
  Future<void> cancelScheduleReminders(int scheduleId) async {
    await _notifications.cancel(scheduleId * 10 + 1);
    await _notifications.cancel(scheduleId * 10 + 2);
    debugPrint('❌ All reminders for schedule $scheduleId cancelled');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('❌ All notifications cancelled');
  }
}
