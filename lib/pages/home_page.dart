import 'package:flutter/material.dart';

import '../database/plant_database.dart';
import '../models/plant.dart';
import '../theme/app_colors.dart';

import 'add_plant_page.dart';
import 'today_page.dart';
import 'calendar_page.dart';
import 'notes_page.dart';
import 'ai_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  int _todayNeedWaterCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardInfo();
  }

  Future<void> _loadDashboardInfo() async {
    setState(() => _loading = true);

    final plants = await PlantDatabase.instance.getAllPlants();
    final now = DateTime.now();

    int count = 0;
    for (final p in plants) {
      final last = p.lastWatered;
      final diffDays = now.difference(last).inDays;
      if (diffDays >= p.frequency) count++;
    }

    if (!mounted) return;
    setState(() {
      _todayNeedWaterCount = count;
      _loading = false;
    });
  }

  /// ✅ Ortak animasyonlu geçiş
  PageRouteBuilder<T> _buildPageRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }

  Future<void> _addPlant() async {
    final newPlant = await Navigator.of(
      context,
    ).push<Plant>(_buildPageRoute<Plant>(const AddPlantPage()));

    if (newPlant != null) {
      await PlantDatabase.instance.insertPlant(newPlant);
      await _loadDashboardInfo(); // ✅ Home özetini güncelle
    }
  }

  /// ✅ Büyük dashboard kartı
  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              AppColors.midGreen.withValues(alpha: 0.85),
              AppColors.darkGreen.withValues(alpha: 0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 34),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(bool isTr) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.05,
      children: [
        _dashboardCard(
          icon: Icons.check_circle,
          title: isTr ? 'Bugün' : 'Today',
          subtitle: isTr ? 'Bugünkü görevler' : "Today's tasks",
          onTap: () =>
              Navigator.of(context).push(_buildPageRoute(const TodayPage())),
        ),
        _dashboardCard(
          icon: Icons.calendar_month,
          title: isTr ? 'Takvim' : 'Calendar',
          subtitle: isTr ? 'Sulama planı' : 'Watering plan',
          onTap: () =>
              Navigator.of(context).push(_buildPageRoute(const CalendarPage())),
        ),
        _dashboardCard(
          icon: Icons.notes,
          title: isTr ? 'Notlar' : 'Notes',
          subtitle: isTr ? 'Bitki notların' : 'Your plant notes',
          onTap: () =>
              Navigator.of(context).push(_buildPageRoute(const NotesPage())),
        ),
        _dashboardCard(
          icon: Icons.auto_awesome,
          title: isTr ? 'AI Öneri' : 'AI Advice',
          subtitle: isTr ? 'Sor, çözüm al' : 'Ask & get help',
          onTap: () =>
              Navigator.of(context).push(_buildPageRoute(const AiPage())),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTr ? 'Bitki Asistanım' : 'Plant Assistant'),
        actions: [
          IconButton(
            tooltip: isTr ? 'Yenile' : 'Refresh',
            onPressed: _loadDashboardInfo,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Mini özet
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Theme.of(context).cardColor.withValues(alpha: 0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _loading
                  ? const Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Yükleniyor...'),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(Icons.water_drop, color: AppColors.midGreen),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isTr
                                ? 'Bugün sulanacak bitki: $_todayNeedWaterCount'
                                : 'Plants to water today: $_todayNeedWaterCount',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            _buildDashboard(isTr),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlant,
        child: const Icon(Icons.add),
      ),
    );
  }
}
