import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'daily_checkin';
  static const _notificationId = 0;

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleDailyReminder() async {
    await _plugin.periodicallyShow(
      _notificationId,
      'Daily Check-in',
      'How are you feeling today? 🌟',
      RepeatInterval.daily,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Daily Check-in',
          channelDescription: 'Daily mental health check-in reminder',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  static Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_notificationId);
  }
}
