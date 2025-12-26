import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../main.dart'; // AppLanguage
import '../services/notification_service.dart';
import '../database/plant_database.dart';

class SettingsPage extends StatefulWidget {
  final ThemeMode themeMode;
  final AppLanguage language;
  final void Function(ThemeMode theme, AppLanguage language) onChanged;

  const SettingsPage({
    super.key,
    required this.themeMode,
    required this.language,
    required this.onChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifEnabled = true;
  TimeOfDay _notifTime = const TimeOfDay(hour: 9, minute: 0);
  bool _busy = false;

  bool get _isTr =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'tr';

  @override
  void initState() {
    super.initState();
    _loadNotifPrefs();
  }

  // ================== PREFS (KALICILIK) ==================
  Future<void> _loadNotifPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final enabled = prefs.getBool('notifEnabled') ?? true;
    final hour = prefs.getInt('notifHour') ?? 9;
    final minute = prefs.getInt('notifMinute') ?? 0;

    if (!mounted) return;
    setState(() {
      _notifEnabled = enabled;
      _notifTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveNotifPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifEnabled', _notifEnabled);
    await prefs.setInt('notifHour', _notifTime.hour);
    await prefs.setInt('notifMinute', _notifTime.minute);
  }

  // ================== DUE COUNT (UYARISIZ + DOĞRU MANTIK) ==================
  Future<int> _calcTodayDueCount() async {
    final plants = await PlantDatabase.instance.getAllPlants();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int count = 0;

    for (final p in plants) {
      final last = p.lastWatered; // DateTime (null değil)
      final lastDate = DateTime(last.year, last.month, last.day);

      final nextWater = lastDate.add(Duration(days: p.frequency));
      final nextDate = DateTime(nextWater.year, nextWater.month, nextWater.day);

      final diff = nextDate.difference(today).inDays;

      // bugün veya gecikmişse
      if (diff <= 0) count++;
    }

    return count;
  }

  // ================== SCHEDULE APPLY ==================
  Future<void> _applySchedule() async {
    setState(() => _busy = true);
    try {
      // ✅ önce prefs kaydet
      await _saveNotifPrefs();

      if (!_notifEnabled) {
        await NotificationService.instance.cancelTodaySummary();
        return;
      }

      final count = await _calcTodayDueCount();

      if (count <= 0) {
        await NotificationService.instance.cancelTodaySummary();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isTr
                  ? 'Bugün sulama yok, bildirim kurulmadı.'
                  : 'No watering today, notification not scheduled.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      await NotificationService.instance.scheduleDailyTodaySummary(
        count: count,
        isTr: _isTr,
        hour: _notifTime.hour,
        minute: _notifTime.minute,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isTr
                ? 'Bildirim saati ayarlandı: ${_notifTime.format(context)}'
                : 'Notification time set: ${_notifTime.format(context)}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isTr ? 'Ayarlar' : 'Settings';
    final themeTitle = _isTr ? 'Tema' : 'Theme';
    final langTitle = _isTr ? 'Dil' : 'Language';
    final notifTitle = _isTr ? 'Bildirim' : 'Notifications';

    final lightText = _isTr ? 'Açık Mod' : 'Light Mode';
    final darkText = _isTr ? 'Koyu Mod' : 'Dark Mode';

    const trText = 'Türkçe';
    const enText = 'English';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================== TEMA ==================
          Text(
            themeTitle,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      widget.onChanged(ThemeMode.light, widget.language),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.themeMode == ThemeMode.light
                            ? AppColors.midGreen
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.light_mode,
                          color: widget.themeMode == ThemeMode.light
                              ? AppColors.midGreen
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(height: 4),
                        Text(lightText),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      widget.onChanged(ThemeMode.dark, widget.language),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.themeMode == ThemeMode.dark
                            ? AppColors.midGreen
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.dark_mode,
                          color: widget.themeMode == ThemeMode.dark
                              ? AppColors.midGreen
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(height: 4),
                        Text(darkText),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ================== DİL ==================
          Text(
            langTitle,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      widget.onChanged(widget.themeMode, AppLanguage.tr),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.language == AppLanguage.tr
                            ? AppColors.midGreen
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: widget.language == AppLanguage.tr
                                ? AppColors.midGreen
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(trText),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      widget.onChanged(widget.themeMode, AppLanguage.en),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.language == AppLanguage.en
                            ? AppColors.midGreen
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'EN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: widget.language == AppLanguage.en
                                ? AppColors.midGreen
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(enText),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ================== BİLDİRİM ==================
          Text(
            notifTitle,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _isTr ? 'Günlük sulama hatırlatması' : 'Daily watering reminder',
            ),
            subtitle: Text(
              _isTr
                  ? 'Her gün seçtiğin saatte özet bildirim'
                  : 'A summary notification at your chosen time every day',
            ),
            value: _notifEnabled,
            onChanged: _busy
                ? null
                : (v) async {
                    setState(() => _notifEnabled = v);
                    await _applySchedule();
                  },
          ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            enabled: _notifEnabled && !_busy,
            leading: const Icon(Icons.access_time),
            title: Text(_isTr ? 'Bildirim saati' : 'Notification time'),
            subtitle: Text(_notifTime.format(context)),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _notifTime,
              );
              if (picked == null) return;
              setState(() => _notifTime = picked);
              await _applySchedule();
            },
          ),

          if (_busy) const LinearProgressIndicator(minHeight: 3),
        ],
      ),
    );
  }
}
