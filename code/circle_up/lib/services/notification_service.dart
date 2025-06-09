import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service responsible for handling local notifications in the app.
/// Manages notification permissions, scheduling, and display for alarm reminders.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  final bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // init
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Request notification permissions
    await Permission.notification.request();

    // Initialize notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to the circle feed
    // This would require a way to communicate with the app's navigation
    // For now, we'll just print the payload
    print('Notification tapped: ${response.payload}');
  }

  /// Returns the notification details configuration
  /// Sets up the Android notification channel with high priority
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_alarm_channel',
        'Daily Alarm Notifications',
        channelDescription: 'Daily alarm notifications for Circle Up',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  /// Shows an immediate notification
  ///
  /// [id] - Unique identifier for the notification (defaults to 0)
  /// [title] - Notification title
  /// [body] - Notification message
  /// [payload] - Optional data to be passed with the notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    return _notifications.show(id, title, body, notificationDetails());
  }

  /// Schedules a notification for a specific time
  ///
  /// [id] - Unique identifier for the notification (defaults to 1)
  /// [title] - Notification title
  /// [body] - Notification message
  /// [hour] - Hour of the day (0-23)
  /// [minute] - Minute of the hour (0-59)
  Future<void> scheduleAlarm({
    required String circleId,
    required String circleName,
    required DateTime alarmTime,
    required String prompt,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'alarm_circles',
      'Alarm Circles',
      channelDescription: 'Notifications for alarm circles',
      importance: Importance.high,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('alarm'),
      playSound: true,
      enableVibration: true,
    );

    final iosDetails = DarwinNotificationDetails(
      sound: 'alarm.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule notification for the next occurrence of the alarm time
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarmTime.hour,
      alarmTime.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      circleId.hashCode,
      'Alarm Circle: $circleName',
      'Time to share your morning routine! Prompt: $prompt',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: circleId,
    );
  }

  /// Requests notification permission from the user
  /// Checks current permission status and requests if not granted
  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (result != PermissionStatus.granted) {
        // print("Notification permission not granted");
      }
    }
  }

  Future<void> cancelAlarm(String circleId) async {
    await _notifications.cancel(circleId.hashCode);
  }

  Future<void> cancelAllAlarms() async {
    await _notifications.cancelAll();
  }
}
