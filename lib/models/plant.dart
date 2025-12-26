class Plant {
  final int? id;
  final String name;
  final String type;
  final int frequency; // sulama aralığı (gün)
  final DateTime lastWatered;
  final String? imagePath; // 🌿 YENİ: fotoğraf dosya yolu

  Plant({
    this.id,
    required this.name,
    required this.type,
    required this.frequency,
    required this.lastWatered,
    this.imagePath,
  });

  Plant copyWith({
    int? id,
    String? name,
    String? type,
    int? frequency,
    DateTime? lastWatered,
    String? imagePath,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      lastWatered: lastWatered ?? this.lastWatered,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'frequency': frequency,
      'lastWatered': lastWatered.millisecondsSinceEpoch,
      'imagePath': imagePath, // 🌿 YENİ
    };
  }

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? '',
      frequency: map['frequency'] as int? ?? 1,
      lastWatered: DateTime.fromMillisecondsSinceEpoch(
        map['lastWatered'] as int,
      ),
      imagePath: map['imagePath'] as String?, // 🌿 YENİ
    );
  }

  @override
  String toString() {
    return 'Plant(id: $id, name: $name, type: $type, '
        'freq: $frequency, last: $lastWatered, imagePath: $imagePath)';
  }
}
