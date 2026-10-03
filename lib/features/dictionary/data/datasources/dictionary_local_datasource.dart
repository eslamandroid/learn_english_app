import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../shared/enums/cefr_level.dart';

abstract class DictionaryLocalDataSource {
  Future<List<Map<String, Object?>>> search({
    String? query,
    CefrLevel? level,
    int limit,
    int offset,
  });

  Future<Map<String, Object?>?> getById(int id);
}

@LazySingleton(as: DictionaryLocalDataSource)
class DictionaryLocalDataSourceImpl implements DictionaryLocalDataSource {
  final Database _db;

  DictionaryLocalDataSourceImpl(@Named('content') this._db);

  @override
  Future<List<Map<String, Object?>>> search({
    String? query,
    CefrLevel? level,
    int limit = 50,
    int offset = 0,
  }) {
    final clauses = <String>[];
    final args = <Object?>[];

    final trimmed = query?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      clauses.add('(word LIKE ? OR word_ar LIKE ?)');
      final needle = '%${_escape(trimmed)}%';
      args..add(needle)..add(needle);
    }
    if (level != null) {
      clauses.add('level = ?');
      args.add(level.label);
    }

    return _db.query(
      'word_list',
      where: clauses.isEmpty ? null : clauses.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'word COLLATE NOCASE ASC',
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<Map<String, Object?>?> getById(int id) async {
    final rows = await _db.query(
      'word_list',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// Escape SQLite LIKE wildcards (`%`, `_`). We're not using an ESCAPE
  /// clause (default escape char doesn't exist), so just strip them — a
  /// dictionary search doesn't need to match on literal `%` characters.
  String _escape(String raw) => raw.replaceAll('%', '').replaceAll('_', '');
}
