import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/user_db_schema.dart';

abstract class MyWordsLocalDataSource {
  /// Lowercase set of saved words — used to annotate [DictionaryWord.isSaved]
  /// for a page of search results in a single query.
  Future<Set<String>> getSavedWordsLower();

  /// Every row, newest first. Returns raw maps so the repository can map them
  /// into the shared [DictionaryWord] entity.
  Future<List<Map<String, Object?>>> getAll();

  Future<void> save({
    required String word,
    required String translation,
    required int sourceId,
  });

  Future<void> remove(String word);
}

@LazySingleton(as: MyWordsLocalDataSource)
class MyWordsLocalDataSourceImpl implements MyWordsLocalDataSource {
  final Database _db;

  MyWordsLocalDataSourceImpl(@Named('user') this._db);

  @override
  Future<Set<String>> getSavedWordsLower() async {
    final rows = await _db.query(
      UserDbSchema.tMyWordList,
      columns: ['word'],
    );
    return rows.map((r) => (r['word'] as String).toLowerCase()).toSet();
  }

  @override
  Future<List<Map<String, Object?>>> getAll() => _db.query(
        UserDbSchema.tMyWordList,
        orderBy: 'created_at DESC, id DESC',
      );

  @override
  Future<void> save({
    required String word,
    required String translation,
    required int sourceId,
  }) async {
    await _db.insert(
      UserDbSchema.tMyWordList,
      {
        'word': word,
        'translation': translation,
        'source_table': 'word_list',
        'source_id': sourceId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      // UNIQUE(word COLLATE NOCASE) index means duplicates are silently
      // dropped — spam-tapping the save star is a no-op.
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  Future<void> remove(String word) async {
    await _db.delete(
      UserDbSchema.tMyWordList,
      where: 'word = ? COLLATE NOCASE',
      whereArgs: [word],
    );
  }
}
