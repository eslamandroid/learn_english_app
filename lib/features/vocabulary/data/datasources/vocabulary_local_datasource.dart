import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../models/vocabulary_subtopic_model.dart';
import '../models/vocabulary_topic_model.dart';
import '../models/vocabulary_word_model.dart';

abstract class VocabularyLocalDataSource {
  Future<List<VocabularyTopicModel>> getTopics();
  Future<List<VocabularyTopicModel>> getTopicsForLevel(int levelId);

  Future<List<VocabularySubtopicModel>> getSubtopics(int topicId);
  Future<VocabularySubtopicModel?> getSubtopic(int subtopicId);

  Future<List<VocabularyWordModel>> getWords(int subtopicId);

  /// `subtopicId → word count` for every subtopic — used to hydrate the
  /// subtopic list without an N+1 fetch.
  Future<Map<int, int>> getWordCountsBySubtopic();

  /// `topicId → total word count across all its subtopics` — used to render
  /// the topic grid's "N Words" metric in one aggregate query.
  Future<Map<int, int>> getWordCountsByTopic();
}

@LazySingleton(as: VocabularyLocalDataSource)
class VocabularyLocalDataSourceImpl implements VocabularyLocalDataSource {
  final Database _database;

  VocabularyLocalDataSourceImpl(this._database);

  @override
  Future<List<VocabularyTopicModel>> getTopics() async {
    final result = await _database.query('vocaTopic', orderBy: 'topicId ASC');
    return result.map(VocabularyTopicModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<VocabularyTopicModel>> getTopicsForLevel(int levelId) async {
    final result = await _database.rawQuery(
      '''
      SELECT vt.* FROM vocaTopic vt
      INNER JOIN level_vocabulary_topic lvt ON vt.topicId = lvt.topicId
      WHERE lvt.levelId = ?
      ORDER BY vt.topicId ASC
      ''',
      [levelId],
    );
    return result.map(VocabularyTopicModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<VocabularySubtopicModel>> getSubtopics(int topicId) async {
    final result = await _database.query(
      'vocaSubTopic',
      where: 'topicId = ?',
      whereArgs: [topicId],
      orderBy: 'id ASC',
    );
    return result.map(VocabularySubtopicModel.fromMap).toList(growable: false);
  }

  @override
  Future<VocabularySubtopicModel?> getSubtopic(int subtopicId) async {
    final result = await _database.query(
      'vocaSubTopic',
      where: 'id = ?',
      whereArgs: [subtopicId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return VocabularySubtopicModel.fromMap(result.first);
  }

  @override
  Future<List<VocabularyWordModel>> getWords(int subtopicId) async {
    final result = await _database.query(
      'vocabulary',
      where: 'subTopicId = ?',
      whereArgs: [subtopicId],
      orderBy: 'id ASC',
    );
    return result.map(VocabularyWordModel.fromMap).toList(growable: false);
  }

  @override
  Future<Map<int, int>> getWordCountsBySubtopic() async {
    final rows = await _database.rawQuery(
      'SELECT subTopicId, COUNT(*) c FROM vocabulary GROUP BY subTopicId',
    );
    return {
      for (final r in rows) (r['subTopicId'] as int): (r['c'] as int),
    };
  }

  @override
  Future<Map<int, int>> getWordCountsByTopic() async {
    final rows = await _database.rawQuery(
      '''
      SELECT vs.topicId AS topicId, COUNT(*) c
      FROM vocabulary v
      INNER JOIN vocaSubTopic vs ON v.subTopicId = vs.id
      GROUP BY vs.topicId
      ''',
    );
    return {
      for (final r in rows) (r['topicId'] as int): (r['c'] as int),
    };
  }
}
