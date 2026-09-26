import 'package:injectable/injectable.dart';

import '../../domain/entities/vocabulary_subtopic.dart';
import '../../domain/entities/vocabulary_topic.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../datasources/vocabulary_local_datasource.dart';

@LazySingleton(as: VocabularyRepository)
class VocabularyRepositoryImpl implements VocabularyRepository {
  final VocabularyLocalDataSource _localDataSource;

  VocabularyRepositoryImpl(this._localDataSource);

  @override
  Future<List<VocabularyTopic>> getTopics() async {
    final topics = await _localDataSource.getTopics();
    return _withWordCounts(topics);
  }

  @override
  Future<List<VocabularyTopic>> getTopicsForLevel(int levelId) async {
    final topics = await _localDataSource.getTopicsForLevel(levelId);
    return _withWordCounts(topics);
  }

  Future<List<VocabularyTopic>> _withWordCounts(
    List<VocabularyTopic> topics,
  ) async {
    final counts = await _localDataSource.getWordCountsByTopic();
    return topics
        .map((t) => t.copyWith(wordCount: counts[t.id] ?? 0))
        .toList(growable: false);
  }

  @override
  Future<List<VocabularySubtopic>> getSubtopics(int topicId) async {
    final subtopics = await _localDataSource.getSubtopics(topicId);
    final counts = await _localDataSource.getWordCountsBySubtopic();
    return subtopics
        .map((s) => s.copyWith(wordCount: counts[s.id] ?? 0))
        .toList(growable: false);
  }

  @override
  Future<List<VocabularyWord>> getWords(int subtopicId) =>
      _localDataSource.getWords(subtopicId);
}
