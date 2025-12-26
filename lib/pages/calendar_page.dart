import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../database/plant_database.dart';
import '../models/plant.dart';
import '../theme/app_colors.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Plant> _plants = [];

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    final list = await PlantDatabase.instance.getAllPlants();
    if (!mounted) return;
    setState(() => _plants = list);
  }

  List<Plant> _plantsForDay(DateTime day) {
    return _plants.where((p) {
      final nextWater = p.lastWatered.add(Duration(days: p.frequency));
      return nextWater.year == day.year &&
          nextWater.month == day.month &&
          nextWater.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final calLocale = isTr ? 'tr_TR' : 'en_US'; // ✅ KRİTİK: TableCalendar dili

    return Scaffold(
      appBar: AppBar(
        title: Text(isTr ? "Sulama Takvimi" : "Watering Calendar"),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: calLocale, // ✅ Ay adı, günler, “2 weeks” buradan düzelir
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2035),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: {
              CalendarFormat.month: isTr ? 'Ay' : 'Month',
              CalendarFormat.twoWeeks: isTr ? '2 hafta' : '2 weeks',
              CalendarFormat.week: isTr ? 'Hafta' : 'Week',
            }, // ✅ format butonu yazısı da TR/EN
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: (day) => _plantsForDay(day),
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: AppColors.midGreen,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: _selectedDay == null
                ? Center(
                    child: Text(isTr ? "Bir gün seçiniz." : "Select a day."),
                  )
                : ListView(
                    children: _plantsForDay(_selectedDay!).map((p) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_florist,
                              color: AppColors.midGreen,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                p.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
