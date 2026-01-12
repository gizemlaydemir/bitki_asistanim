import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// databaseFactory için gerekir
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app_navigator.dart'; // navigatorKey burada
import 'database/plant_database.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'pages/main_scaffold.dart';
import 'pages/intro_page.dart';
import 'pages/today_page.dart';

import 'pages/plants_page.dart';

enum AppLanguage { tr, en }

// ---------------- PREFS (APP) ----------------
const _kThemeKey = 'appThemeMode'; // 0:light, 1:dark
const _kLangKey = 'appLanguage'; // 'tr' / 'en'
const _kStartedKey = 'appStarted'; // intro geçildi mi

// ---------------- PREFS (NOTIF) ----------------
const _kNotifEnabledKey = 'notifEnabled';
const _kNotifHourKey = 'notifHour';
const _kNotifMinuteKey = 'notifMinute';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('tr_TR', null);

  final prefs = await SharedPreferences.getInstance();
  final themeIndex = prefs.getInt(_kThemeKey) ?? 0;
  final langStr = prefs.getString(_kLangKey) ?? 'tr';
  final started = prefs.getBool(_kStartedKey) ?? false;

  final initialTheme = themeIndex == 1 ? ThemeMode.dark : ThemeMode.light;
  final initialLanguage = (langStr == 'en') ? AppLanguage.en : AppLanguage.tr;

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await PlantDatabase.instance.database;

  await NotificationService.instance.init();

  try {
    await _syncDailySummaryFromPrefs(prefs, initialLanguage);
  } catch (e, st) {
    debugPrint('❌ Daily summary notification sync failed: $e');
    debugPrint('$st');
    try {
      await NotificationService.instance.cancelTodaySummary();
    } catch (_) {}
  }

  runApp(
    MyApp(
      initialThemeMode: initialTheme,
      initialLanguage: initialLanguage,
      initialStarted: started,
    ),
  );
}

Future<int> _calcTodayDueCount() async {
  final allPlants = await PlantDatabase.instance.getAllPlants();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  int count = 0;

  for (final p in allPlants) {
    final last = p.lastWatered;
    final lastDate = DateTime(last.year, last.month, last.day);

    final nextWater = lastDate.add(Duration(days: p.frequency));
    final nextDate = DateTime(nextWater.year, nextWater.month, nextWater.day);

    final diff = nextDate.difference(today).inDays;

    if (diff <= 0) count++;
  }

  return count;
}

Future<void> _syncDailySummaryFromPrefs(
  SharedPreferences prefs,
  AppLanguage language,
) async {
  final enabled = prefs.getBool(_kNotifEnabledKey) ?? true;
  final hour = prefs.getInt(_kNotifHourKey) ?? 9;
  final minute = prefs.getInt(_kNotifMinuteKey) ?? 0;

  if (!enabled) {
    await NotificationService.instance.cancelTodaySummary();
    return;
  }

  final count = await _calcTodayDueCount();

  if (count <= 0) {
    await NotificationService.instance.cancelTodaySummary();
    return;
  }

  final isTr = language == AppLanguage.tr;

  await NotificationService.instance.scheduleDailyTodaySummary(
    count: count,
    isTr: isTr,
    hour: hour,
    minute: minute,
  );
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final AppLanguage initialLanguage;
  final bool initialStarted;

  const MyApp({
    super.key,
    required this.initialThemeMode,
    required this.initialLanguage,
    required this.initialStarted,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;
  late AppLanguage _language;
  late bool _started;

  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    _themeMode = widget.initialThemeMode;
    _language = widget.initialLanguage;
    _started = widget.initialStarted;

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  Future<void> _saveAppPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeKey, _themeMode == ThemeMode.dark ? 1 : 0);
    await prefs.setString(_kLangKey, _language == AppLanguage.en ? 'en' : 'tr');
    await prefs.setBool(_kStartedKey, _started);
  }

  void _applySettings(ThemeMode theme, AppLanguage language) {
    setState(() {
      _themeMode = theme;
      _language = language;
      _started = true;
    });

    _saveAppPrefs();
  }

  @override
  Widget build(BuildContext context) {
    final locale = _language == AppLanguage.tr
        ? const Locale('tr', 'TR')
        : const Locale('en', 'US');

    Intl.defaultLocale = '${locale.languageCode}_${locale.countryCode}';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Bitki Asistanım",
      navigatorKey: navigatorKey,

      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],

      // ✅ DÜZELTİLDİ
      routes: {
        '/today': (_) => const TodayPage(),
        '/plants': (_) => const PlantsPage(),
      },

      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (child, animation) {
          final slide =
              Tween<Offset>(
                begin: const Offset(0.0, 0.08),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: _showSplash
            ? const SplashScreen(key: ValueKey('splash'))
            : _started
            ? MainScaffold(
                key: const ValueKey('main'),
                language: _language,
                themeMode: _themeMode,
                onSettingsChanged: _applySettings,
              )
            : IntroPage(
                key: const ValueKey('intro'),
                initialThemeMode: _themeMode,
                initialLanguage: _language,
                onStart: _applySettings,
              ),
      ),
    );
  }
}

// ================== SPLASH ==================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _animate ? 1 : 0,
              curve: Curves.easeOut,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 800),
                scale: _animate ? 1 : 0.7,
                curve: Curves.easeOutBack,
                child: Icon(
                  Icons.local_florist,
                  size: 72,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 900),
              opacity: _animate ? 1 : 0,
              curve: Curves.easeOut,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 900),
                offset: _animate ? Offset.zero : const Offset(0, 0.2),
                curve: Curves.easeOut,
                child: const Text(
                  "Bitki Asistanım",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
