import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/plant_database.dart';
import '../models/plant.dart';
import '../theme/app_colors.dart';

class PlantsPage extends StatefulWidget {
  const PlantsPage({super.key});

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  bool _loading = true;
  List<Plant> _plants = [];

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() => _loading = true);
    final plants = await PlantDatabase.instance.getAllPlants();
    if (!mounted) return;
    setState(() {
      _plants = plants;
      _loading = false;
    });
  }

  void _showPlantDetails(Plant p) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final last = p.lastWatered;
    final lastDate = DateTime(last.year, last.month, last.day);

    final next = lastDate.add(Duration(days: p.frequency));
    final nextDate = DateTime(next.year, next.month, next.day);

    final remaining = nextDate.difference(today).inDays;

    final dateFmt = DateFormat('dd.MM.yyyy');

    String remainingText;
    if (remaining <= 0) {
      remainingText = isTr
          ? 'Bugün sulanmalı / gecikmiş'
          : 'Due today / overdue';
    } else {
      remainingText = isTr ? '$remaining gün kaldı' : '$remaining days left';
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),

              _detailRow(
                icon: Icons.water_drop,
                text: isTr
                    ? "En son sulama: ${dateFmt.format(lastDate)}"
                    : "Last watered: ${dateFmt.format(lastDate)}",
              ),
              const SizedBox(height: 10),

              _detailRow(
                icon: Icons.schedule,
                text: isTr
                    ? "Sulama sıklığı: ${p.frequency} günde bir"
                    : "Frequency: every ${p.frequency} days",
              ),
              const SizedBox(height: 10),

              _detailRow(
                icon: Icons.calendar_month,
                text: isTr
                    ? "Bir sonraki sulama: ${dateFmt.format(nextDate)}"
                    : "Next watering: ${dateFmt.format(nextDate)}",
              ),
              const SizedBox(height: 10),

              _detailRow(icon: Icons.timelapse, text: remainingText),

              const SizedBox(height: 14),

              // İstersen buraya buton ekleyebiliriz:
              // "Şimdi suladım" -> lastWatered güncelle
              // updatePlant/copyWith durumuna göre yapalım.
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.midGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
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
        title: Text(isTr ? 'Tüm Bitkilerim' : 'All Plants'),
        actions: [
          IconButton(
            tooltip: isTr ? 'Yenile' : 'Refresh',
            onPressed: _loadPlants,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _plants.isEmpty
          ? Center(
              child: Text(
                isTr ? 'Henüz bitki eklenmemiş 🌱' : 'No plants yet 🌱',
                style: const TextStyle(fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _plants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = _plants[index];
                final now = DateTime.now();

                final diffDays = now.difference(p.lastWatered).inDays;
                final remaining = p.frequency - diffDays;

                final subtitle = remaining <= 0
                    ? (isTr ? 'Bugün sulanır' : 'Water today')
                    : (isTr
                          ? '$remaining gün sonra sulanır'
                          : 'Water in $remaining days');

                final String title = p.name;
                final String? imagePath = p.imagePath;

                Widget leading = Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.midGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.local_florist,
                    color: AppColors.midGreen,
                  ),
                );

                if (imagePath != null && imagePath.isNotEmpty) {
                  final file = File(imagePath);
                  if (file.existsSync()) {
                    leading = ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        file,
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                }

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _showPlantDetails(p),
                  child: Container(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withValues(alpha: 0.60),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
