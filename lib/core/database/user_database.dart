import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import 'user_db_schema.dart';

class UserDatabase {
  UserDatabase._();

  static Database? _database;

  static Future<Database> open() async {
    if (_database != null) return _database!;

    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDir.path, AppConstants.userDbFileName);

    _database = await openDatabase(
      dbPath,
      version: AppConstants.userDbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.transaction((txn) async {
          for (final sql in UserDbSchema.v1Statements) {
            await txn.execute(sql);
          }
          for (final sql in UserDbSchema.v2Statements) {
            await txn.execute(sql);
          }
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.transaction((txn) async {
          if (oldVersion < 2) {
            for (final sql in UserDbSchema.v2Statements) {
              await txn.execute(sql);
            }
          }
        });
      },
    );

    return _database!;
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
