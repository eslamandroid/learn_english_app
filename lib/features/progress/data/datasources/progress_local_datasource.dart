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

  // ─── Sentences (subtopics) ────────────────────────────────────────────
  Future<Set<int>> getCompletedSentencesSubtopics();
  Future<int?> getInProgressSentencesSubtopic();
  Future<void> setInProgressSentencesSubtopic(int? id);
  Future<void> markSentencesSubtopicCompleted(int id);

  // ─── Sentences per-lesson rows (v2) ──────────────────────────────────
  /// Returns every row of `sentence_lesson_progress`, keyed by lessonId.
  Future<Map<int, SentenceLessonProgressRow>> getSentenceLessonRows();

  /// Upserts the per-lesson row, bumping [seen] to max(existing, [seen])
  /// and keeping [total] authoritative. Does not touch `completedAt`.
  Future<void> recordSentenceLessonSeen({
    required int lessonId,
    required int seen,
    required int total,
  });

  /// Sets `seen = total` and stamps `completedAt = ISO now`.
  Future<void> markSentenceLessonCompleted({
    required int lessonId,
    required int total,
  });
}

/// Plain row carrier between the data layer and the repository mapper.
class SentenceLessonProgressRow {
  final int lessonId;
  final int seen;
  final int total;
  final String? completedAt;

  const SentenceLessonProgressRow({
    required this.lessonId,
    required this.seen,
    required this.total,
    this.completedAt,
  });
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

  // ─── Sentences ────────────────────────────────────────────────────────

  @override
  Future<Set<int>> getCompletedSentencesSubtopics() =>
      _getCompleted(UserDbSchema.srcSentencesSubTopic);

  @override
  Future<int?> getInProgressSentencesSubtopic() =>
      _getInProgress(UserDbSchema.srcSentencesSubTopic);

  @override
  Future<void> setInProgressSentencesSubtopic(int? id) =>
      _setInProgress(UserDbSchema.srcSentencesSubTopic, id);

  @override
  Future<void> markSentencesSubtopicCompleted(int id) =>
      _markCompleted(UserDbSchema.srcSentencesSubTopic, id);

  // ─── Sentences per-lesson rows (v2) ──────────────────────────────────

  @override
  Future<Map<int, SentenceLessonProgressRow>> getSentenceLessonRows() async {
    final rows = await _db.query(UserDbSchema.tSentenceLessonProgress);
    return {
      for (final r in rows)
        r['lessonId'] as int: SentenceLessonProgressRow(
          lessonId: r['lessonId'] as int,
          seen: r['seen'] as int? ?? 0,
          total: r['total'] as int? ?? 0,
          completedAt: r['completedAt'] as String?,
        ),
    };
  }

  @override
  Future<void> recordSentenceLessonSeen({
    required int lessonId,
    required int seen,
    required int total,
  }) async {
    // Keep max(seen) across repeat visits; preserve any existing completedAt.
    await _db.rawInsert('''
      INSERT INTO ${UserDbSchema.tSentenceLessonProgress}
        (lessonId, seen, total, completedAt)
      VALUES (?, ?, ?, NULL)
      ON CONFLICT(lessonId) DO UPDATE SET
        seen  = MAX(seen, excluded.seen),
        total = excluded.total
    ''', [lessonId, seen, total]);
  }

  @override
  Future<void> markSentenceLessonCompleted({
    required int lessonId,
    required int total,
  }) async {
    final now = DateTime.now().toIso8601String();
    await _db.rawInsert('''
      INSERT INTO ${UserDbSchema.tSentenceLessonProgress}
        (lessonId, seen, total, completedAt)
      VALUES (?, ?, ?, ?)
      ON CONFLICT(lessonId) DO UPDATE SET
        seen        = excluded.total,
        total       = excluded.total,
        completedAt = excluded.completedAt
    ''', [lessonId, total, total, now]);
  }
}
