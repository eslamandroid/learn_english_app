import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/database/user_db_migrator.dart';
import 'package:learn_english_app/core/database/user_db_schema.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.transaction((txn) async {
            for (final sql in UserDbSchema.v1Statements) {
              await txn.execute(sql);
            }
          });
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<SharedPreferences> prefsWithData() async {
    SharedPreferences.setMockInitialValues({
      'grammar.completed_subtopics': '[1, 2, 3]',
      'grammar.in_progress_subtopic': 4,
      'phonetics.completed_topics': '[10, 11]',
      'phonetics.in_progress_topic': 12,
      'selected_level': 2,
      'selected_voice': 'us_male',
      'language_code': 'ar',
    });
    return SharedPreferences.getInstance();
  }

  Future<List<Map<String, Object?>>> progressRows(
    String sourceTable,
    int status,
  ) => db.query(
    UserDbSchema.tUserProgress,
    where: 'source_table = ? AND status = ?',
    whereArgs: [sourceTable, status],
  );

  Future<String?> getSetting(String key) async {
    final rows = await db.query(
      UserDbSchema.tUserSettings,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  test('prefs with data → user.db gets correct rows + migration_done=1', () async {
    final prefs = await prefsWithData();
    await UserDbMigrator.runIfNeeded(prefs, db);

    // Grammar completed: 1, 2, 3
    final grammarCompleted = await progressRows(
      UserDbSchema.srcGrammarSubTopics,
      UserDbSchema.statusCompleted,
    );
    expect(grammarCompleted.map((r) => r['source_id']).toSet(), {1, 2, 3});

    // Grammar in_progress: 4
    final grammarInProgress = await progressRows(
      UserDbSchema.srcGrammarSubTopics,
      UserDbSchema.statusInProgress,
    );
    expect(grammarInProgress.map((r) => r['source_id']).toSet(), {4});

    // Phonetics completed: 10, 11
    final phoneticsCompleted = await progressRows(
      UserDbSchema.srcPhoneticTopic,
      UserDbSchema.statusCompleted,
    );
    expect(phoneticsCompleted.map((r) => r['source_id']).toSet(), {10, 11});

    // Phonetics in_progress: 12
    final phoneticsInProgress = await progressRows(
      UserDbSchema.srcPhoneticTopic,
      UserDbSchema.statusInProgress,
    );
    expect(phoneticsInProgress.map((r) => r['source_id']).toSet(), {12});

    // Settings
    expect(await getSetting(UserDbSchema.keyLevel), '2');
    expect(await getSetting(UserDbSchema.keyVoiceKey), 'us_male');
    expect(await getSetting(UserDbSchema.keyExplanationLocale), 'ar');
    expect(await getSetting(UserDbSchema.keyMigrationDone), '1');
  });

  test('running twice does not duplicate rows', () async {
    final prefs = await prefsWithData();
    await UserDbMigrator.runIfNeeded(prefs, db);
    await UserDbMigrator.runIfNeeded(prefs, db);

    final all = await db.query(
      UserDbSchema.tUserProgress,
      where: 'source_table = ?',
      whereArgs: [UserDbSchema.srcGrammarSubTopics],
    );
    // 3 completed + 1 in_progress = 4 rows exactly
    expect(all.length, 4);
  });

  test('empty prefs → migration_done=1 with no progress rows', () async {
    final prefs = await SharedPreferences.getInstance();
    await UserDbMigrator.runIfNeeded(prefs, db);

    final allProgress = await db.query(UserDbSchema.tUserProgress);
    expect(allProgress, isEmpty);
    expect(await getSetting(UserDbSchema.keyMigrationDone), '1');
  });

  test('corrupt JSON in prefs → no exception, migration completes', () async {
    SharedPreferences.setMockInitialValues({
      'grammar.completed_subtopics': '{not valid json}',
      'phonetics.completed_topics': 'also broken',
    });
    final prefs = await SharedPreferences.getInstance();

    expect(
      () => UserDbMigrator.runIfNeeded(prefs, db),
      returnsNormally,
    );
    await UserDbMigrator.runIfNeeded(prefs, db);
    expect(await getSetting(UserDbSchema.keyMigrationDone), '1');
  });
}
