import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/database/user_db_schema.dart';
import 'package:learn_english_app/features/progress/data/datasources/progress_local_datasource.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late ProgressLocalDataSourceImpl sut;

  setUp(() async {
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
    sut = ProgressLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ─── Grammar ────────────────────────────────────────────────────────────

  test('markCompleted then getCompleted returns the id', () async {
    await sut.markGrammarSubtopicCompleted(42);
    final completed = await sut.getCompletedGrammarSubtopics();
    expect(completed, contains(42));
  });

  test('setInProgress(a) then setInProgress(b) — only b is in_progress', () async {
    await sut.setInProgressGrammarSubtopic(1);
    await sut.setInProgressGrammarSubtopic(2);
    final inProgress = await sut.getInProgressGrammarSubtopic();
    expect(inProgress, 2);
  });

  test('setInProgress on completed id does not change status', () async {
    await sut.markGrammarSubtopicCompleted(5);
    await sut.setInProgressGrammarSubtopic(5);
    final completed = await sut.getCompletedGrammarSubtopics();
    expect(completed, contains(5));
    // It should not be in_progress — previous in_progress was cleared and 5
    // was skipped because it's completed.
    final inProgress = await sut.getInProgressGrammarSubtopic();
    expect(inProgress, isNull);
  });

  test('markCompleted on in_progress clears the in_progress', () async {
    await sut.setInProgressGrammarSubtopic(7);
    expect(await sut.getInProgressGrammarSubtopic(), 7);
    await sut.markGrammarSubtopicCompleted(7);
    // status is now completed — getInProgress returns null
    final inProgress = await sut.getInProgressGrammarSubtopic();
    expect(inProgress, isNull);
    expect(await sut.getCompletedGrammarSubtopics(), contains(7));
  });

  test('attempts increments with each markCompleted', () async {
    await sut.markGrammarSubtopicCompleted(10);
    await sut.markGrammarSubtopicCompleted(10);
    await sut.markGrammarSubtopicCompleted(10);
    final rows = await db.query(
      UserDbSchema.tUserProgress,
      where: 'source_table = ? AND source_id = ?',
      whereArgs: [UserDbSchema.srcGrammarSubTopics, 10],
    );
    expect(rows.first['attempts'], 3);
  });

  // ─── Phonetics ──────────────────────────────────────────────────────────

  test('phonetics markCompleted + getCompleted works independently', () async {
    await sut.markPhoneticTopicCompleted(99);
    final completed = await sut.getCompletedPhoneticTopics();
    expect(completed, contains(99));
    // Grammar should be unaffected.
    final grammarCompleted = await sut.getCompletedGrammarSubtopics();
    expect(grammarCompleted, isEmpty);
  });

  test('grammar and phonetics in_progress are isolated', () async {
    await sut.setInProgressGrammarSubtopic(11);
    await sut.setInProgressPhoneticTopic(22);
    expect(await sut.getInProgressGrammarSubtopic(), 11);
    expect(await sut.getInProgressPhoneticTopic(), 22);
  });

  test('writing to grammar does not appear in phonetics', () async {
    await sut.markGrammarSubtopicCompleted(3);
    final phoneticsCompleted = await sut.getCompletedPhoneticTopics();
    expect(phoneticsCompleted, isEmpty);
  });
}
