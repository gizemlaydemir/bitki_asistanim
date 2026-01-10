import 'dart:io';

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

  // ✅ tüm bitkiler listesi
  List<Plant> _plants = [];

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
      _plants = plants;
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
      await _loadDashboardInfo();
    }
  }

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

  Widget _fallbackIconBox() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.midGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.local_florist, color: AppColors.midGreen),
    );
  }

  // ✅ “Tüm Bitkilerim” bölümü
  Widget _allPlantsSection(bool isTr) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isTr
                  ? 'Tüm Bitkilerim (${_plants.length})'
                  : 'All My Plants (${_plants.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            TextButton(
              onPressed: () {
                // ✅ Tüm bitkilerin göründüğü sayfa
                Navigator.pushNamed(context, '/plants');
              },
              child: Text(isTr ? 'Tümünü gör' : 'See all'),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_loading)
          const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_plants.isEmpty)
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
            child: Row(
              children: [
                const Icon(Icons.local_florist, color: AppColors.midGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isTr
                        ? 'Henüz bitki eklemedin. + butonuyla ekleyebilirsin 🌱'
                        : "You haven't added any plants yet. Tap + to add 🌱",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 132,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _plants.length,
              itemBuilder: (context, index) {
                final p = _plants[index];

                // Sulamaya kaç gün kaldı?
                final diffDays = now.difference(p.lastWatered).inDays;
                final remaining = p.frequency - diffDays;

                final subtitle = remaining <= 0
                    ? (isTr ? 'Bugün sulanır' : 'Water today')
                    : (isTr ? '$remaining gün sonra' : 'In $remaining days');

                // ✅ Bitki adı (Plant modelinde name varsa)
                final plantName = p.name;

                // ✅ Görsel (Plant modelinde imagePath varsa)
                final String? imagePath = p.imagePath;

                Widget leading = _fallbackIconBox();
                if (imagePath != null && imagePath.isNotEmpty) {
                  final file = File(imagePath);
                  if (file.existsSync()) {
                    leading = ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        file,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                }

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    // İstersen burada bitki detay sayfasına gidebilir.
                  },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Theme.of(
                        context,
                      ).cardColor.withValues(alpha: 0.95),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.midGreen.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        leading,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plantName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.60),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
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
                  ? Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text(isTr ? 'Yükleniyor...' : 'Loading...'),
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

            const SizedBox(height: 18),
            _allPlantsSection(isTr),
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
