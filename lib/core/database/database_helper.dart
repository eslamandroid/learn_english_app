import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static Database? _database;

  static Future<Database> initDatabase() async {
    if (_database != null) return _database!;

    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDir.path, AppConstants.dbFileName);

    if (!await File(dbPath).exists()) {
      final data = await rootBundle.load(AppConstants.dbAssetPath);
      final bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    _database = await openDatabase(dbPath, readOnly: false);
    return _database!;
  }

  static Future<Database> get database async {
    return _database ?? await initDatabase();
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
