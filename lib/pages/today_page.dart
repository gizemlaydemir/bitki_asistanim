import 'package:flutter/material.dart';

import '../database/plant_database.dart';
import '../models/plant.dart';
import '../widgets/plant_card.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  bool _loading = true;
  List<Plant> _todayPlants = [];

  @override
  void initState() {
    super.initState();
    _loadTodayPlants();
  }

  Future<void> _loadTodayPlants() async {
    setState(() => _loading = true);

    final allPlants = await PlantDatabase.instance.getAllPlants();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<Plant> due = [];

    for (final p in allPlants) {
      final last = p.lastWatered;
      final lastDate = DateTime(last.year, last.month, last.day);

      final nextWater = lastDate.add(Duration(days: p.frequency));
      final nextDate = DateTime(nextWater.year, nextWater.month, nextWater.day);

      final diff = nextDate.difference(today).inDays;

      // Bugün veya gecikmişse
      if (diff <= 0) {
        due.add(p);
      }
    }

    if (!mounted) return;

    setState(() {
      _todayPlants = due;
      _loading = false;
    });
  }

  Future<void> _waterPlant(Plant plant) async {
    final updated = Plant(
      id: plant.id,
      name: plant.name,
      type: plant.type,
      frequency: plant.frequency,
      lastWatered: DateTime.now(),
    );

    await PlantDatabase.instance.updatePlant(updated);
    await _loadTodayPlants(); // sadece liste yenilenir
  }

  Future<void> _deletePlant(Plant plant) async {
    if (plant.id == null) return;
    await PlantDatabase.instance.deletePlant(plant.id!);
    await _loadTodayPlants();
  }

  @override
  Widget build(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';

    return Scaffold(
      appBar: AppBar(title: Text(isTr ? 'Bugünkü Görevler' : "Today's Tasks")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _todayPlants.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  isTr
                      ? 'Şu an yapılacak sulama görevi yok. Bitkilerin çok mutlu görünüyor 🌱'
                      : 'No plants need watering today. Your plants look very happy 🌱',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTodayPlants,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _todayPlants.length,
                itemBuilder: (context, index) {
                  final p = _todayPlants[index];
                  return PlantCard(
                    plant: p,
                    onWater: () => _waterPlant(p),
                    onDelete: () => _deletePlant(p),
                  );
                },
              ),
            ),
    );
  }
}
