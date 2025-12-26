import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import '../database/plant_database.dart';

class StartupService {
  static Future<void> applySavedNotificationSettings({
    required bool isTr,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final enabled = prefs.getBool('notifEnabled') ?? true;
    final hour = prefs.getInt('notifHour') ?? 9;
    final minute = prefs.getInt('notifMinute') ?? 0;

    if (!enabled) {
      await NotificationService.instance.cancelTodaySummary();
      return;
    }

    // Bugün sulanacak bitki sayısını hesapla
    final plants = await PlantDatabase.instance.getAllPlants();
    final now = DateTime.now();

    int count = 0;
    for (final p in plants) {
      final last = p.lastWatered;
      final diffDays = now.difference(last).inDays;
      if (diffDays >= p.frequency) count++;
    }

    if (count == 0) {
      await NotificationService.instance.cancelTodaySummary();
      return;
    }

    await NotificationService.instance.scheduleDailyTodaySummary(
      count: count,
      isTr: isTr,
      hour: hour,
      minute: minute,
    );
  }
}
