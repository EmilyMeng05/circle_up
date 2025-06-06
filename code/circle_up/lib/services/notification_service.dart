import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service responsible for handling local notifications in the app.
/// Manages notification permissions, scheduling, and display for alarm reminders.
class NotificationService {
  final notifPlugin = FlutterLocalNotificationsPlugin();

  final bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // init
  Future<void> initNotification() async {
    if (_isInitialized) return;

    // android initialization settings
    const initAndroidSettings = AndroidInitializationSettings(
      'mipmap/ic_launcher',
    );

    // iOS-specific initialization settings
    final DarwinInitializationSettings initIOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: initAndroidSettings,
      iOS: initIOSSettings,
    );

    // Initialize timezone
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    await notifPlugin.initialize(initSettings);
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
    return notifPlugin.show(id, title, body, notificationDetails());
  }

  /// Schedules a notification for a specific time
  ///
  /// [id] - Unique identifier for the notification (defaults to 1)
  /// [title] - Notification title
  /// [body] - Notification message
  /// [hour] - Hour of the day (0-23)
  /// [minute] - Minute of the hour (0-59)
  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    // Create scheduled date time using current date and specified time
    var scheduledDateTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Schedule the notification using Android's alarm clock mode for reliability
    await notifPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDateTime,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.alarmClock
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
}
