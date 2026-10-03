import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/database/user_db_schema.dart';
import 'package:learn_english_app/features/dictionary/data/datasources/my_words_local_datasource.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late MyWordsLocalDataSourceImpl sut;

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
    sut = MyWordsLocalDataSourceImpl(db);
  });

  tearDown(() async => db.close());

  test('save then getSavedWordsLower returns the word (lowercased)', () async {
    await sut.save(word: 'Apple', translation: 'تفاح', sourceId: 42);
    final saved = await sut.getSavedWordsLower();
    expect(saved, contains('apple'));
  });

  test('save twice (same word) is a no-op — UNIQUE(word COLLATE NOCASE)', () async {
    await sut.save(word: 'apple', translation: 'تفاح', sourceId: 1);
    await sut.save(word: 'APPLE', translation: 'تفاح', sourceId: 1);
    final rows = await sut.getAll();
    expect(rows.length, 1);
  });

  test('remove deletes by word (case-insensitive)', () async {
    await sut.save(word: 'apple', translation: 'تفاح', sourceId: 1);
    await sut.remove('APPLE');
    final rows = await sut.getAll();
    expect(rows, isEmpty);
  });

  test('getAll returns newest first', () async {
    await sut.save(word: 'first', translation: 'أول', sourceId: 1);
    await Future.delayed(const Duration(milliseconds: 10));
    await sut.save(word: 'second', translation: 'ثاني', sourceId: 2);
    final rows = await sut.getAll();
    expect(rows.first['word'], 'second');
    expect(rows.last['word'], 'first');
  });

  test('isolated from unrelated tables in user.db', () async {
    // Writing a progress row shouldn't be visible in my_word_list calls, and
    // writing a my_word_list row shouldn't appear in progress calls.
    await db.insert(UserDbSchema.tUserProgress, {
      'source_table': 'grammar_sub_topics',
      'source_id': 1,
      'status': UserDbSchema.statusCompleted,
      'attempts': 1,
      'completed_at': 0,
    });
    await sut.save(word: 'word', translation: 'كلمة', sourceId: 5);
    final saved = await sut.getSavedWordsLower();
    expect(saved, {'word'});
    final progress = await db.query(UserDbSchema.tUserProgress);
    expect(progress.length, 1);
  });
}
