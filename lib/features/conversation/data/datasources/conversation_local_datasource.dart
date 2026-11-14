import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../models/conversation_category_model.dart';
import '../models/conversation_lesson_model.dart';
import '../models/conversation_line_model.dart';

abstract class ConversationLocalDataSource {
  Future<List<ConversationCategoryModel>> getCategories();

  /// Returns lessons for [categoryId] along with each lesson's lineCount —
  /// grouped in a single query via LEFT JOIN + COUNT so we don't pay 1+N
  /// round-trips.
  Future<List<ConversationLessonModel>> getLessons(int categoryId);

  Future<List<ConversationLineModel>> getLines(int lessonId);
}

@LazySingleton(as: ConversationLocalDataSource)
class ConversationLocalDataSourceImpl implements ConversationLocalDataSource {
  final Database _db;

  ConversationLocalDataSourceImpl(@Named('content') this._db);

  @override
  Future<List<ConversationCategoryModel>> getCategories() async {
    final rows = await _db.query('conversation_level', orderBy: 'id ASC');
    return rows
        .map(ConversationCategoryModel.fromMap)
        .toList(growable: false);
  }

  @override
  Future<List<ConversationLessonModel>> getLessons(int categoryId) async {
    // Keep the FK column selection explicit so the row maps cleanly even if
    // the generic `*` ordering changes in a future migration.
    final rows = await _db.rawQuery(
      '''
      SELECT
        l.id            AS id,
        l.level_id      AS level_id,
        l.title         AS title,
        l.titleAr       AS titleAr,
        l.duration      AS duration,
        (
          SELECT COUNT(*) FROM conversation_sentence s
          WHERE s.lesson = l.id
        ) AS line_count
      FROM conversation_lesson l
      WHERE l.level_id = ?
      ORDER BY l.id ASC
      ''',
      [categoryId],
    );
    return rows
        .map(ConversationLessonModel.fromMap)
        .toList(growable: false);
  }

  @override
  Future<List<ConversationLineModel>> getLines(int lessonId) async {
    // `conversation_sentence.lesson` (not `lessonId`) is the FK, per §1a.
    final rows = await _db.query(
      'conversation_sentence',
      where: 'lesson = ?',
      whereArgs: [lessonId],
      orderBy: 'id ASC',
    );
    return rows.map(ConversationLineModel.fromMap).toList(growable: false);
  }
}
