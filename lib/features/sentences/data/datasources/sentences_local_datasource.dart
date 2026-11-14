import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../models/sentence_item_model.dart';
import '../models/sentence_subtopic_model.dart';
import '../models/sentence_topic_model.dart';

abstract class SentencesLocalDataSource {
  Future<List<SentenceTopicModel>> getTopics();
  Future<List<SentenceSubtopicModel>> getSubtopics(int topicId);
  Future<List<SentenceSubtopicModel>> getAllSubtopics();
  Future<List<SentenceItemModel>> getSentences(int subtopicId);
}

@LazySingleton(as: SentencesLocalDataSource)
class SentencesLocalDataSourceImpl implements SentencesLocalDataSource {
  final Database _db;

  SentencesLocalDataSourceImpl(@Named('content') this._db);

  @override
  Future<List<SentenceTopicModel>> getTopics() async {
    final rows = await _db.query('sentenceTopic', orderBy: 'topicId ASC');
    return rows.map(SentenceTopicModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<SentenceSubtopicModel>> getSubtopics(int topicId) async {
    final rows = await _db.query(
      'sentencesSubTopic',
      where: 'topicId = ?',
      whereArgs: [topicId],
      orderBy: 'subTopicId ASC',
    );
    return rows.map(SentenceSubtopicModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<SentenceSubtopicModel>> getAllSubtopics() async {
    final rows = await _db.query(
      'sentencesSubTopic',
      orderBy: 'topicId ASC, subTopicId ASC',
    );
    return rows.map(SentenceSubtopicModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<SentenceItemModel>> getSentences(int subtopicId) async {
    final rows = await _db.query(
      'sentencesContent',
      where: 'subTopicId = ?',
      whereArgs: [subtopicId],
      orderBy: 'id ASC',
    );
    return rows.map(SentenceItemModel.fromMap).toList(growable: false);
  }
}
