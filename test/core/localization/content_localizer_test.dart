import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/database/user_db_schema.dart';
import 'package:learn_english_app/core/localization/content_localizer_impl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  final sut = ContentLocalizerImpl.instance;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute(UserDbSchema.createUserSettings);
        },
      ),
    );
  });

  tearDown(() async {
    sut.debugReset();
    await db.close();
  });

  // ── bind() ─────────────────────────────────────────────────────────────────

  test('bind() with no stored locale → currentLocale == ar', () async {
    await sut.bind(db);
    expect(sut.currentLocale, 'ar');
  });

  test('bind() with stored "en" → currentLocale still ar (critical: no confusion with UI lang)', () async {
    await db.insert(UserDbSchema.tUserSettings, {
      'key': UserDbSchema.keyExplanationLocale,
      'value': 'en',
    });
    await sut.bind(db);
    // CRITICAL: 'en' is a UI language code that may have been migrated from
    // legacy prefs. It must NOT be used as the content explanation locale.
    expect(sut.currentLocale, 'ar');
  });

  test('bind() with stored "ar" → currentLocale == ar', () async {
    await db.insert(UserDbSchema.tUserSettings, {
      'key': UserDbSchema.keyExplanationLocale,
      'value': 'ar',
    });
    await sut.bind(db);
    expect(sut.currentLocale, 'ar');
  });

  test('bind() with stored "tr" → currentLocale still ar (not supported in v1.0)', () async {
    await db.insert(UserDbSchema.tUserSettings, {
      'key': UserDbSchema.keyExplanationLocale,
      'value': 'tr',
    });
    await sut.bind(db);
    expect(sut.currentLocale, 'ar');
  });

  // ── localize() — ar locale ─────────────────────────────────────────────────

  test('localize() ar + non-empty arabicValue → returns arabicValue', () async {
    await sut.bind(db);
    final result = sut.localize(
      sourceTable: 'vocabulary',
      sourceId: 1,
      field: 'ita',
      englishValue: 'Hello',
      arabicValue: 'مرحبا',
    );
    expect(result, 'مرحبا');
  });

  test('localize() ar + empty arabicValue → returns englishValue', () async {
    await sut.bind(db);
    final result = sut.localize(
      sourceTable: 'vocabulary',
      sourceId: 1,
      field: 'ita',
      englishValue: 'Hello',
      arabicValue: '',
    );
    expect(result, 'Hello');
  });

  test('localize() ar + null arabicValue → returns englishValue', () async {
    await sut.bind(db);
    final result = sut.localize(
      sourceTable: 'vocabulary',
      sourceId: 1,
      field: 'ita',
      englishValue: 'Hello',
      arabicValue: null,
    );
    expect(result, 'Hello');
  });

  // ── localize() — non-ar locale (1.2 readiness) ────────────────────────────

  test('localize() tr with cached translation → returns cached text', () async {
    await sut.bind(db);
    sut.debugSetLocale('tr');
    sut.debugAddTranslation(
      sourceTable: 'vocabulary',
      sourceId: 42,
      field: 'ita',
      locale: 'tr',
      text: 'Merhaba',
    );
    final result = sut.localize(
      sourceTable: 'vocabulary',
      sourceId: 42,
      field: 'ita',
      englishValue: 'Hello',
      arabicValue: 'مرحبا',
    );
    expect(result, 'Merhaba');
  });

  test('localize() tr with no cached translation → returns englishValue', () async {
    await sut.bind(db);
    sut.debugSetLocale('tr');
    final result = sut.localize(
      sourceTable: 'vocabulary',
      sourceId: 99,
      field: 'ita',
      englishValue: 'Hello',
      arabicValue: 'مرحبا',
    );
    expect(result, 'Hello');
  });
}
