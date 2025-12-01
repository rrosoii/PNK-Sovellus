import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    // Request runtime permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleHydrationReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'hydration_channel',
      'Hydration Reminders',
      channelDescription: 'Muistutukset veden juomisesta ja kirjaamisesta',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Cancel any existing reminder with this ID to avoid duplicates
    await _plugin.cancel(1001);

    // Repeat every 2 hours
    await _plugin.periodicallyShow(
      1001,
      'Muistutus',
      'Kirjaa tämänhetkinen vedenjuonti.',
      RepeatInterval.hourly,
      details,
      androidAllowWhileIdle: true,
    );
  }
}
