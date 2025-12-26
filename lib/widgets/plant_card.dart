import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/plant.dart';
import '../theme/app_colors.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onWater;
  final VoidCallback onDelete;
  final VoidCallback? onImageTap; // 🌿 resme tıklama (nullable)

  const PlantCard({
    super.key,
    required this.plant,
    required this.onWater,
    required this.onDelete,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';

    // 🔢 Tarih hesapları
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      plant.lastWatered.year,
      plant.lastWatered.month,
      plant.lastWatered.day,
    );
    final next = last.add(Duration(days: plant.frequency));
    final diffDays = next.difference(today).inDays;

    final dateFormat = DateFormat('dd.MM.yyyy');

    String statusText;
    Color statusColor;

    if (diffDays < 0) {
      // gecikmiş
      statusText = isTr
          ? '${diffDays.abs()} gün gecikti'
          : '${diffDays.abs()} day(s) late';
      statusColor = Colors.red;
    } else if (diffDays == 0) {
      statusText = isTr ? 'Bugün sulanmalı' : 'Needs watering today';
      statusColor = Colors.red;
    } else {
      statusText = isTr ? '$diffDays gün kaldı' : '$diffDays day(s) remaining';
      statusColor = AppColors.darkGreen;
    }

    final lastText = dateFormat.format(last);
    final nextText = dateFormat.format(next);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Theme.of(context).cardColor.withOpacity(0.97),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📷 FOTO / İKON – TIKLANABİLİR
          GestureDetector(
            onTap: onImageTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                width: 52,
                height: 52,
                child: plant.imagePath != null && plant.imagePath!.isNotEmpty
                    ? Image.file(File(plant.imagePath!), fit: BoxFit.cover)
                    : Container(
                        // ignore: deprecated_member_use
                        color: AppColors.lightGreen.withOpacity(0.3),
                        child: const Icon(
                          Icons.local_florist,
                          color: AppColors.darkGreen,
                          size: 28,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // METİN TARAFI
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (isTr ? 'Tür: ' : 'Type: ') + plant.type,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 6),

                // 📅 TARİHLER
                Text(
                  (isTr ? 'Son sulama: ' : 'Last watering: ') + lastText,
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  (isTr ? 'Sonraki sulama: ' : 'Next watering: ') + nextText,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),

          // SAĞDA SU & ÇÖP BUTONLARI
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.water_drop, color: AppColors.midGreen),
                onPressed: onWater,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
