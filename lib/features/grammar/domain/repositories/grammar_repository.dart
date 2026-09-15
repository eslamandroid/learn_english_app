import '../entities/grammar_lesson.dart';
import '../entities/grammar_rule_test.dart';
import '../entities/grammar_subtopic.dart';
import '../entities/grammar_topic.dart';

abstract class GrammarRepository {
  /// All topics with their subtopic counts populated.
  Future<List<GrammarTopic>> getTopics();

  /// Topics available at the given CEFR level (1..6).
  Future<List<GrammarTopic>> getTopicsForLevel(int levelId);

  /// Subtopics for one topic with their rule counts populated.
  Future<List<GrammarSubtopic>> getSubtopics(int topicId);

  /// Fully-hydrated lesson (subtopic + rules + descriptions + examples).
  Future<GrammarLesson?> getLesson(int subtopicId);

  /// All rule-level tests for one subtopic.
  Future<List<GrammarRuleTest>> getRuleTests(int subtopicId);
}
