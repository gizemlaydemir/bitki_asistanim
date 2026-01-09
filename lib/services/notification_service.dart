import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _todaySummaryId = 9001;

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (_) {}
  }

  AndroidNotificationDetails _androidDetails() {
    return const AndroidNotificationDetails(
      'water_channel',
      'Sulama Bildirimleri',
      channelDescription: 'Bitki sulama hatırlatmaları',
      importance: Importance.max,
      priority: Priority.high,
    );
  }

  Future<void> cancelTodaySummary() async {
    await _plugin.cancel(_todaySummaryId);
  }

  /// ✅ Her gün seçilen saatte özet bildirim kurar.
  /// count=0 ise kurmaz (cancel eder).
  Future<void> scheduleDailyTodaySummary({
    required int count,
    required bool isTr,
    required int hour,
    required int minute,
  }) async {
    if (count <= 0) {
      await cancelTodaySummary();
      return;
    }

    final title = isTr ? 'Bitki Asistanım' : 'Plant Assistant';
    final body = isTr
        ? 'Bugün sulanması gereken $count bitki var 💧'
        : 'You have $count plants to water today 💧';

    final details = NotificationDetails(
      android: _androidDetails(),
      iOS: const DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _todaySummaryId,
      title,
      body,
      scheduled,
      details,

      // ✅ CRASH'i çözen değişiklik:
      // exactAllowWhileIdle -> inexactAllowWhileIdle
      // Böylece Android "exact alarms not permitted" hatası vermez.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
