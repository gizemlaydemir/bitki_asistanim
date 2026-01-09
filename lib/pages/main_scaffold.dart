import 'package:flutter/material.dart';
import '../main.dart'; // AppLanguage enum için
import 'home_page.dart';
import 'calendar_page.dart';
import 'today_page.dart';
import 'donation_page.dart';
import 'settings_page.dart';

class MainScaffold extends StatefulWidget {
  final AppLanguage language;
  final ThemeMode themeMode;
  final void Function(ThemeMode theme, AppLanguage language) onSettingsChanged;

  const MainScaffold({
    super.key,
    required this.language,
    required this.themeMode,
    required this.onSettingsChanged,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // MENU LABELS
  String _labelPlants() =>
      widget.language == AppLanguage.tr ? 'Bitkiler' : 'Plants';

  String _labelCalendar() =>
      widget.language == AppLanguage.tr ? 'Takvim' : 'Calendar';

  String _labelToday() => widget.language == AppLanguage.tr ? 'Bugün' : 'Today';

  String _labelDonation() =>
      widget.language == AppLanguage.tr ? 'Bağış' : 'Donate';

  String _labelSettings() =>
      widget.language == AppLanguage.tr ? 'Ayarlar' : 'Settings';

  // SAYFA GEÇİŞİ
  Widget _buildPage() {
    switch (_currentIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const CalendarPage();
      case 2:
        return const TodayPage();
      case 3:
        return const DonationPage();
      case 4:
        return SettingsPage(
          themeMode: widget.themeMode,
          language: widget.language,
          onChanged: widget.onSettingsChanged,
        );
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SAYFA ANİMASYONU
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(animation);

          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: fade, child: child),
          );
        },
        child: KeyedSubtree(key: ValueKey(_currentIndex), child: _buildPage()),
      ),

      // ALT MENÜ
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: widget.themeMode == ThemeMode.dark
            ? Colors.black
            : Colors.white,
        selectedItemColor: widget.themeMode == ThemeMode.dark
            ? const Color(0xFF66BB6A)
            : const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() => _currentIndex = index);
        },

        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_florist),
            label: _labelPlants(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: _labelCalendar(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.today),
            label: _labelToday(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.volunteer_activism),
            label: _labelDonation(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: _labelSettings(),
          ),
        ],
      ),
    );
  }
}
