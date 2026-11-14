import '../entities/vocabulary_subtopic.dart';
import '../entities/vocabulary_topic.dart';
import '../entities/vocabulary_word.dart';

abstract class VocabularyRepository {
  /// All 14 topics — the DB already stores `subTopicCount` on each row.
  Future<List<VocabularyTopic>> getTopics();

  /// Topics available at the given CEFR level (1..6).
  Future<List<VocabularyTopic>> getTopicsForLevel(int levelId);

  /// Subtopics for one topic, with each subtopic's word count populated.
  Future<List<VocabularySubtopic>> getSubtopics(int topicId);

  /// All words in one subtopic.
  Future<List<VocabularyWord>> getWords(int subtopicId);
}
