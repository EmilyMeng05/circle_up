import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    return notifPlugin.show(id, title, body, notificationDetails());
  }

  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    // get the minute and hour from the scheduled time

    // final scheduledHour = scheduledTime.hour;
    // final scheduledMinute = scheduledTime.minute;

    var scheduledDateTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    await notifPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDateTime,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.alarmClock
    );
    // print('Scheduled notification for $scheduledDateTime');
  }

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
