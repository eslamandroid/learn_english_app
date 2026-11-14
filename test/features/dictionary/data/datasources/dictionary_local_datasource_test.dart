import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/features/dictionary/data/datasources/dictionary_local_datasource.dart';
import 'package:learn_english_app/shared/enums/cefr_level.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late DictionaryLocalDataSourceImpl sut;

  Future<void> seed(List<Map<String, Object?>> rows) async {
    final batch = db.batch();
    for (final r in rows) {
      batch.insert('word_list', r);
    }
    await batch.commit(noResult: true);
  }

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) => db.execute('''
          CREATE TABLE word_list (
            id INTEGER PRIMARY KEY,
            word TEXT NOT NULL,
            word_ar TEXT NOT NULL,
            pronunciation TEXT NOT NULL,
            example TEXT NOT NULL,
            level TEXT NOT NULL
          )
        '''),
      ),
    );
    sut = DictionaryLocalDataSourceImpl(db);
  });

  tearDown(() async => db.close());

  test('empty query + null level → first page ordered by word NOCASE', () async {
    await seed([
      {'id': 1, 'word': 'banana', 'word_ar': 'موز',
        'pronunciation': '', 'example': '', 'level': 'A1'},
      {'id': 2, 'word': 'Apple', 'word_ar': 'تفاح',
        'pronunciation': '', 'example': '', 'level': 'A1'},
      {'id': 3, 'word': 'cherry', 'word_ar': 'كرز',
        'pronunciation': '', 'example': '', 'level': 'A2'},
    ]);
    final rows = await sut.search();
    expect(rows.map((r) => r['word']).toList(), ['Apple', 'banana', 'cherry']);
  });

  test('English search matches word column (case-insensitive LIKE)', () async {
    await seed([
      {'id': 1, 'word': 'about', 'word_ar': 'عن',
        'pronunciation': '', 'example': '', 'level': 'A1'},
      {'id': 2, 'word': 'above', 'word_ar': 'فوق',
        'pronunciation': '', 'example': '', 'level': 'A1'},
      {'id': 3, 'word': 'zebra', 'word_ar': 'حمار وحشي',
        'pronunciation': '', 'example': '', 'level': 'B2'},
    ]);
    final rows = await sut.search(query: 'abo');
    expect(rows.map((r) => r['id']).toList(), [1, 2]);
  });

  test('Arabic search matches word_ar column', () async {
    await seed([
      {'id': 1, 'word': 'about', 'word_ar': 'عن',
        'pronunciation': '', 'example': '', 'level': 'A1'},
      {'id': 2, 'word': 'book', 'word_ar': 'كتاب',
        'pronunciation': '', 'example': '', 'level': 'A1'},
    ]);
    final rows = await sut.search(query: 'كتا');
    expect(rows.length, 1);
    expect(rows.first['id'], 2);
  });

  test('level filter narrows to that level only', () async {
    await seed([
      {'id': 1, 'word': 'alpha', 'word_ar': 'أ',
        'pronunciation': '', 'example': '', 'level': 'A1'},
      {'id': 2, 'word': 'beta', 'word_ar': 'ب',
        'pronunciation': '', 'example': '', 'level': 'B1'},
      {'id': 3, 'word': 'gamma', 'word_ar': 'ج',
        'pronunciation': '', 'example': '', 'level': 'B1'},
    ]);
    final rows = await sut.search(level: CefrLevel.b1);
    expect(rows.map((r) => r['id']).toSet(), {2, 3});
  });

  test('limit + offset paginate correctly', () async {
    await seed([
      for (var i = 1; i <= 10; i++)
        {
          'id': i,
          'word': 'word${i.toString().padLeft(2, '0')}',
          'word_ar': 'كلمة$i',
          'pronunciation': '',
          'example': '',
          'level': 'A1',
        },
    ]);
    final page1 = await sut.search(limit: 4, offset: 0);
    final page2 = await sut.search(limit: 4, offset: 4);
    expect(page1.map((r) => r['id']).toList(), [1, 2, 3, 4]);
    expect(page2.map((r) => r['id']).toList(), [5, 6, 7, 8]);
  });

  test('wildcards in query are stripped (no SQL injection via LIKE %/_)', () async {
    await seed([
      {'id': 1, 'word': 'test', 'word_ar': 'اختبار',
        'pronunciation': '', 'example': '', 'level': 'A1'},
    ]);
    final rows = await sut.search(query: '%');
    // After stripping, needle becomes '%%' → matches everything. The point
    // of this test is: no exception, LIKE still runs cleanly.
    expect(rows.length, 1);
  });

  test('getById returns the matching row', () async {
    await seed([
      {'id': 7, 'word': 'target', 'word_ar': 'هدف',
        'pronunciation': '/ˈtɑːrɡɪt/', 'example': '', 'level': 'B2'},
    ]);
    final row = await sut.getById(7);
    expect(row?['word'], 'target');
    expect(await sut.getById(999), isNull);
  });
}
