import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/plant.dart';
import '../theme/app_colors.dart';

class AddPlantPage extends StatefulWidget {
  const AddPlantPage({super.key});

  @override
  State<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _freqController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() {
      _imagePath = picked.path;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final type = _typeController.text.trim();
    final freq = int.parse(_freqController.text.trim());

    final plant = Plant(
      name: name,
      type: type,
      frequency: freq,
      lastWatered: DateTime.now(),
      imagePath: _imagePath,
    );

    Navigator.of(context).pop(plant);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _freqController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';

    return Scaffold(
      appBar: AppBar(title: Text(isTr ? 'Yeni Bitki Ekle' : 'Add New Plant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 📷 FOTOĞRAF SEÇME
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightGreen.withValues(alpha: 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _imagePath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_a_photo,
                                size: 32,
                                color: AppColors.darkGreen,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isTr ? 'Fotoğraf ekle' : 'Add photo',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ],
                          )
                        : Image.file(File(_imagePath!), fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 🌿 Bitki adı
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name, // ✅ Türkçe/isim uyumlu
                textCapitalization: TextCapitalization.words,
                enableSuggestions: true,
                autocorrect: true,
                decoration: InputDecoration(
                  labelText: isTr ? 'Bitki Adı' : 'Plant Name',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return isTr
                        ? 'Lütfen bitki adını girin'
                        : 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 🌿 Tür
              TextFormField(
                controller: _typeController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                enableSuggestions: true,
                autocorrect: true,
                decoration: InputDecoration(
                  labelText: isTr
                      ? 'Bitki Türü (örn: Sukulent)'
                      : 'Plant Type (e.g. succulent)',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 💧 Sıklık
              TextFormField(
                controller: _freqController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isTr
                      ? 'Sulama Sıklığı (gün)'
                      : 'Watering Frequency (days)',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return isTr
                        ? 'Lütfen sulama sıklığını girin'
                        : 'Please enter watering frequency';
                  }
                  if (int.tryParse(v.trim()) == null) {
                    return isTr
                        ? 'Lütfen geçerli bir sayı girin'
                        : 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.midGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    isTr ? 'Kaydet' : 'Save',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
