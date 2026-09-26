import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/user_db_schema.dart';

abstract class ProgressLocalDataSource {
  // ─── Grammar (subtopics) ──────────────────────────────────────────────
  Future<Set<int>> getCompletedGrammarSubtopics();
  Future<int?> getInProgressGrammarSubtopic();
  Future<void> setInProgressGrammarSubtopic(int? id);
  Future<void> markGrammarSubtopicCompleted(int id);

  // ─── Phonetics (topics) ───────────────────────────────────────────────
  Future<Set<int>> getCompletedPhoneticTopics();
  Future<int?> getInProgressPhoneticTopic();
  Future<void> setInProgressPhoneticTopic(int? id);
  Future<void> markPhoneticTopicCompleted(int id);
}

@LazySingleton(as: ProgressLocalDataSource)
class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  final Database _db;

  ProgressLocalDataSourceImpl(@Named('user') this._db);

  // ─── Generic helpers ──────────────────────────────────────────────────

  Future<Set<int>> _getCompleted(String sourceTable) async {
    final rows = await _db.query(
      UserDbSchema.tUserProgress,
      columns: ['source_id'],
      where: 'source_table = ? AND status = ?',
      whereArgs: [sourceTable, UserDbSchema.statusCompleted],
    );
    return rows.map((r) => r['source_id'] as int).toSet();
  }

  Future<int?> _getInProgress(String sourceTable) async {
    final rows = await _db.query(
      UserDbSchema.tUserProgress,
      columns: ['source_id'],
      where: 'source_table = ? AND status = ?',
      whereArgs: [sourceTable, UserDbSchema.statusInProgress],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['source_id'] as int;
  }

  Future<void> _setInProgress(String sourceTable, int? id) async {
    await _db.transaction((txn) async {
      // Clear any existing in_progress for this table.
      await txn.update(
        UserDbSchema.tUserProgress,
        {'status': UserDbSchema.statusNone},
        where: 'source_table = ? AND status = ?',
        whereArgs: [sourceTable, UserDbSchema.statusInProgress],
      );

      if (id != null) {
        // Only set in_progress if the row isn't already completed.
        final existing = await txn.query(
          UserDbSchema.tUserProgress,
          columns: ['status'],
          where: 'source_table = ? AND source_id = ?',
          whereArgs: [sourceTable, id],
          limit: 1,
        );
        final alreadyCompleted =
            existing.isNotEmpty &&
            existing.first['status'] as int == UserDbSchema.statusCompleted;
        if (!alreadyCompleted) {
          await txn.insert(
            UserDbSchema.tUserProgress,
            {
              'source_table': sourceTable,
              'source_id': id,
              'status': UserDbSchema.statusInProgress,
              'started_at': DateTime.now().millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  Future<void> _markCompleted(String sourceTable, int id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.rawInsert('''
      INSERT INTO ${UserDbSchema.tUserProgress}
        (source_table, source_id, status, attempts, completed_at)
      VALUES (?, ?, ?, 1, ?)
      ON CONFLICT(source_table, source_id) DO UPDATE SET
        status       = ${UserDbSchema.statusCompleted},
        completed_at = excluded.completed_at,
        attempts     = attempts + 1
    ''', [sourceTable, id, UserDbSchema.statusCompleted, now]);
  }

  // ─── Grammar ──────────────────────────────────────────────────────────

  @override
  Future<Set<int>> getCompletedGrammarSubtopics() =>
      _getCompleted(UserDbSchema.srcGrammarSubTopics);

  @override
  Future<int?> getInProgressGrammarSubtopic() =>
      _getInProgress(UserDbSchema.srcGrammarSubTopics);

  @override
  Future<void> setInProgressGrammarSubtopic(int? id) =>
      _setInProgress(UserDbSchema.srcGrammarSubTopics, id);

  @override
  Future<void> markGrammarSubtopicCompleted(int id) =>
      _markCompleted(UserDbSchema.srcGrammarSubTopics, id);

  // ─── Phonetics ────────────────────────────────────────────────────────

  @override
  Future<Set<int>> getCompletedPhoneticTopics() =>
      _getCompleted(UserDbSchema.srcPhoneticTopic);

  @override
  Future<int?> getInProgressPhoneticTopic() =>
      _getInProgress(UserDbSchema.srcPhoneticTopic);

  @override
  Future<void> setInProgressPhoneticTopic(int? id) =>
      _setInProgress(UserDbSchema.srcPhoneticTopic, id);

  @override
  Future<void> markPhoneticTopicCompleted(int id) =>
      _markCompleted(UserDbSchema.srcPhoneticTopic, id);
}
