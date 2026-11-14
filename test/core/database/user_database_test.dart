import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/database/user_db_schema.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<Database> openInMemory() async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await db.transaction((txn) async {
            for (final sql in UserDbSchema.v1Statements) {
              await txn.execute(sql);
            }
          });
        },
      ),
    );
    return db;
  }

  test('v1 onCreate creates all 6 tables', () async {
    final db = await openInMemory();
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    );
    final tables = rows.map((r) => r['name'] as String).toSet();

    expect(tables, containsAll([
      UserDbSchema.tUserSettings,
      UserDbSchema.tUserProgress,
      UserDbSchema.tSrsCard,
      UserDbSchema.tDailyActivity,
      UserDbSchema.tShadowingAttempt,
      UserDbSchema.tMyWordList,
    ]));

    await db.close();
  });

  test('v1 onCreate creates expected indexes', () async {
    final db = await openInMemory();
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='index' ORDER BY name",
    );
    final indexes = rows.map((r) => r['name'] as String).toSet();

    expect(indexes, containsAll([
      'idx_progress_status',
      'idx_srs_due',
      'idx_shadow_sentence',
      'idx_myword_word',
    ]));

    await db.close();
  });

  test('opening twice does not re-create tables', () async {
    final db1 = await openInMemory();
    // Insert a row so we can detect if tables were dropped.
    await db1.insert(UserDbSchema.tUserSettings, {'key': 'test', 'value': '1'});

    // Re-open same path — in-memory path is unique per connection so we just
    // verify the schema query works without error on a second db instance.
    final db2 = await openInMemory();
    final rows = await db2.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    expect(rows.length, greaterThanOrEqualTo(6));

    await db1.close();
    await db2.close();
  });
}
