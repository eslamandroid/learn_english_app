import 'package:injectable/injectable.dart';

import '../../domain/entities/sentence_item.dart';
import '../../domain/entities/sentence_subtopic.dart';
import '../../domain/entities/sentence_topic.dart';
import '../../domain/repositories/sentences_repository.dart';
import '../datasources/sentences_local_datasource.dart';

@LazySingleton(as: SentencesRepository)
class SentencesRepositoryImpl implements SentencesRepository {
  final SentencesLocalDataSource _local;
  SentencesRepositoryImpl(this._local);

  @override
  Future<List<SentenceTopic>> getTopics() => _local.getTopics();

  @override
  Future<List<SentenceSubtopic>> getSubtopics(int topicId) =>
      _local.getSubtopics(topicId);

  @override
  Future<List<SentenceSubtopic>> getAllSubtopics() =>
      _local.getAllSubtopics();

  @override
  Future<List<SentenceItem>> getSentences(int subtopicId) =>
      _local.getSentences(subtopicId);
}
