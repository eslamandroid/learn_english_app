import '../entities/sentence_item.dart';
import '../entities/sentence_subtopic.dart';
import '../entities/sentence_topic.dart';

abstract class SentencesRepository {
  Future<List<SentenceTopic>> getTopics();
  Future<List<SentenceSubtopic>> getSubtopics(int topicId);
  Future<List<SentenceSubtopic>> getAllSubtopics();
  Future<List<SentenceItem>> getSentences(int subtopicId);
}
