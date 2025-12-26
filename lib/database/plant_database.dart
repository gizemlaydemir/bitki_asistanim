import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/plant.dart';
import '../models/note.dart';

class PlantDatabase {
  PlantDatabase._init();
  static final PlantDatabase instance = PlantDatabase._init();

  static Database? _database;

  static const _dbName = 'plants.db';
  // 🔺 Versiyonu 4 yaptık (notes + imagePath için)
  static const _dbVersion = 4;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
    return _database!;
  }

  Future _createDB(Database db, int version) async {
    // 🌿 Bitki tablosu
    await db.execute('''
      CREATE TABLE plants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        frequency INTEGER NOT NULL,
        lastWatered INTEGER NOT NULL,
        imagePath TEXT
      )
    ''');

    // 🌱 Fidan sayaç tablosu
    await db.execute('''
      CREATE TABLE donations (
        id INTEGER PRIMARY KEY,
        count INTEGER NOT NULL
      )
    ''');

    await db.insert('donations', {'id': 1, 'count': 0});

    // 📝 Notlar tablosu
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS donations (
          id INTEGER PRIMARY KEY,
          count INTEGER NOT NULL
        )
      ''');

      final existing = await db.query(
        'donations',
        where: 'id = ?',
        whereArgs: [1],
        limit: 1,
      );

      if (existing.isEmpty) {
        await db.insert('donations', {'id': 1, 'count': 0});
      }
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL
        )
      ''');
    }

    if (oldVersion < 4) {
      // 🌿 Eski bitkilere fotoğraf kolonunu ekle
      await db.execute('ALTER TABLE plants ADD COLUMN imagePath TEXT;');
    }
  }

  // ---------------------------------------------------------------------------
  // 🌿 BITKI İŞLEMLERİ
  // ---------------------------------------------------------------------------

  Future<List<Plant>> getAllPlants() async {
    final db = await database;
    final result = await db.query('plants', orderBy: 'lastWatered DESC');
    return result.map((e) => Plant.fromMap(e)).toList();
  }

  Future<int> insertPlant(Plant plant) async {
    final db = await database;
    return await db.insert('plants', plant.toMap());
  }

  Future<int> addPlant(Plant plant) async {
    final db = await database;
    return await db.insert('plants', plant.toMap());
  }

  Future<int> updatePlant(Plant plant) async {
    final db = await database;
    return await db.update(
      'plants',
      plant.toMap(),
      where: 'id = ?',
      whereArgs: [plant.id],
    );
  }

  Future<int> deletePlant(int id) async {
    final db = await database;
    return await db.delete('plants', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------------
  // 🌱 FIDAN SAYACI İşlemleri
  // ---------------------------------------------------------------------------

  Future<int> getDonationCount() async {
    final db = await database;
    final result = await db.query(
      'donations',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      await db.insert('donations', {'id': 1, 'count': 0});
      return 0;
    }

    return result.first['count'] as int;
  }

  Future<void> setDonationCount(int count) async {
    final db = await database;
    await db.update(
      'donations',
      {'count': count},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> incrementDonation() async {
    final current = await getDonationCount();
    final newCount = current + 1;
    await setDonationCount(newCount);
    return newCount;
  }

  /// ✅ YENİ: Fidan sayısını sıfırla (0'a çek)
  Future<int> resetDonation() async {
    await setDonationCount(0);
    return 0;
  }

  // ---------------------------------------------------------------------------
  // 📝 NOTLAR İŞLEMLERİ
  // ---------------------------------------------------------------------------

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final result = await db.query('notes', orderBy: 'createdAt DESC');
    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
