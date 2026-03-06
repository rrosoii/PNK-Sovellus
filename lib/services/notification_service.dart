import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification_history_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
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

  /// Schedules a daily notification to remind the user to log exercise.
  Future<void> scheduleDailyExerciseReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'exercise_channel',
      'Exercise Reminders',
      channelDescription: 'Päivittäinen muistutus liikunnan kirjaamisesta',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    // Cancel any existing reminder with this ID to avoid duplicates
    await _plugin.cancel(2001);

    // Schedule for 20:00 (8 PM) every day
    final scheduleTime = DateTime.now().add(Duration(
      hours: 20 - DateTime.now().hour,
      minutes: -DateTime.now().minute,
      seconds: -DateTime.now().second,
    ));
    await _plugin.zonedSchedule(
      2001,
      'Muistutus',
      'Muista kirjata päivän liikunta! 💪',
      tz.TZDateTime.from(scheduleTime, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Shows a notification for a new event and saves it to history.
  Future<void> showNewEventNotification(String title, {String? body}) async {
    const androidDetails = AndroidNotificationDetails(
      'event_channel',
      'Tapahtumat',
      channelDescription: 'Ilmoitukset uusista tapahtumista',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final displayTitle = 'Uusi tapahtuma: $title';
    final displayBody = body ?? 'Katso lisätietoja sovelluksesta.';

    await _plugin.show(
      3001,
      displayTitle,
      displayBody,
      details,
    );

    // Save to notification history
    final historyService = NotificationHistoryService();
    await historyService.addNotification(displayTitle, displayBody);
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
