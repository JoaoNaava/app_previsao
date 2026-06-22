import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_application_1/models/saved_location_model.dart';
import 'package:flutter_application_1/models/weather_model.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'weather_app.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lat REAL NOT NULL,
        lon REAL NOT NULL,
        city_name TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE weather_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lat REAL NOT NULL,
        lon REAL NOT NULL,
        temperature REAL NOT NULL,
        apparent_temperature REAL NOT NULL,
        wind_speed REAL NOT NULL,
        humidity INTEGER NOT NULL,
        weather_code INTEGER NOT NULL,
        temp_min REAL NOT NULL,
        temp_max REAL NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS weather_cache (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          lat REAL NOT NULL,
          lon REAL NOT NULL,
          temperature REAL NOT NULL,
          apparent_temperature REAL NOT NULL,
          wind_speed REAL NOT NULL,
          humidity INTEGER NOT NULL,
          weather_code INTEGER NOT NULL,
          temp_min REAL NOT NULL,
          temp_max REAL NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    }
  }

  // --- Localização ---

  static Future<SavedLocationModel?> getSavedLocation() async {
    if (kIsWeb) return null;
    final db = await database;
    final rows = await db.query('locations', limit: 1);
    if (rows.isEmpty) return null;
    return SavedLocationModel.fromMap(rows.first);
  }

  static Future<void> saveOrUpdateLocation(SavedLocationModel location) async {
    if (kIsWeb) return;
    final db = await database;
    final existing = await db.query('locations', columns: ['id'], limit: 1);
    if (existing.isEmpty) {
      await db.insert('locations', location.toMap());
    } else {
      await db.update(
        'locations',
        location.toMap(),
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  // --- Cache de clima ---

  static Future<void> saveWeather(double lat, double lon, WeatherModel weather) async {
    if (kIsWeb) return;
    final db = await database;
    final existing = await db.query(
      'weather_cache',
      columns: ['id'],
      where: 'ABS(lat - ?) < 0.01 AND ABS(lon - ?) < 0.01',
      whereArgs: [lat, lon],
      limit: 1,
    );
    final data = weather.toMap(lat, lon);
    if (existing.isEmpty) {
      await db.insert('weather_cache', data);
    } else {
      await db.update(
        'weather_cache',
        data,
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  static Future<WeatherModel?> getCachedWeather(double lat, double lon) async {
    if (kIsWeb) return null;
    final db = await database;
    final rows = await db.query(
      'weather_cache',
      where: 'ABS(lat - ?) < 0.01 AND ABS(lon - ?) < 0.01',
      whereArgs: [lat, lon],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WeatherModel.fromMap(rows.first);
  }
}
