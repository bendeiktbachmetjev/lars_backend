import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/foundation.dart';
import 'dart:io';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int dailyNotificationId = 1;

  /// Initialize timezone and notification plugin
  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request Android permissions (required for Android 13+)
    // iOS permissions are requested automatically via DarwinInitializationSettings
    if (Platform.isAndroid) {
      await _requestAndroidPermissions();
    }
  }

  /// Request Android notification permissions (required for Android 13+)
  Future<void> _requestAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      if (kDebugMode) {
        print('Android notification permission granted: $granted');
      }
    }
  }

  /// Handle notification tap - opens the app
  void _onNotificationTapped(NotificationResponse response) {
    // When notification is tapped, app will open automatically
    // The app is already configured to show HomePage as default
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
  }

  /// Schedule daily notification at 19:00 (7 PM)
  Future<void> scheduleDailyNotification({
    required String title,
    required String body,
  }) async {
    // Cancel existing notification if any
    await cancelDailyNotification();

    // Schedule daily notification at 19:00
    await _notificationsPlugin.zonedSchedule(
      dailyNotificationId,
      title,
      body,
      _getNextNotificationTime(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Questionnaire Reminder',
          channelDescription: 'Reminder to fill out daily questionnaire',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Get next notification time (today at 19:00, or tomorrow if already past)
  tz.TZDateTime _getNextNotificationTime() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      19, // 7 PM
      0,  // 0 minutes
    );

    // If it's already past 19:00 today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Cancel the daily notification
  Future<void> cancelDailyNotification() async {
    await _notificationsPlugin.cancel(dailyNotificationId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Check if notification permissions are granted
  Future<bool> arePermissionsGranted() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    // For iOS, permissions are managed by the system
    // Return true as iOS will show permission dialog automatically
    return true;
  }
}

