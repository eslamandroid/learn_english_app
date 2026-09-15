import 'package:injectable/injectable.dart';

import '../../domain/entities/grammar_lesson.dart';
import '../../domain/entities/grammar_rule.dart';
import '../../domain/entities/grammar_rule_test.dart';
import '../../domain/entities/grammar_subtopic.dart';
import '../../domain/entities/grammar_topic.dart';
import '../../domain/repositories/grammar_repository.dart';
import '../datasources/grammar_local_datasource.dart';

@LazySingleton(as: GrammarRepository)
class GrammarRepositoryImpl implements GrammarRepository {
  final GrammarLocalDataSource _localDataSource;

  GrammarRepositoryImpl(this._localDataSource);

  @override
  Future<List<GrammarTopic>> getTopics() async {
    final topics = await _localDataSource.getTopics();
    final counts = await _localDataSource.getSubtopicCountsByTopic();
    return topics
        .map((t) => t.withSubtopicCount(counts[t.id] ?? 0))
        .toList(growable: false);
  }

  @override
  Future<List<GrammarTopic>> getTopicsForLevel(int levelId) async {
    final topics = await _localDataSource.getTopicsForLevel(levelId);
    final counts = await _localDataSource.getSubtopicCountsByTopic();
    return topics
        .map((t) => t.withSubtopicCount(counts[t.id] ?? 0))
        .toList(growable: false);
  }

  @override
  Future<List<GrammarSubtopic>> getSubtopics(int topicId) async {
    final subtopics = await _localDataSource.getSubtopics(topicId);
    final ruleCounts = await _localDataSource.getRuleCountsBySubtopic();

    // Check which subtopics have tests in one query
    final testedSubtopicIds = <int>{};
    for (final st in subtopics) {
      final tests = await _localDataSource.getRuleTestsForSubtopic(st.id);
      if (tests.isNotEmpty) testedSubtopicIds.add(st.id);
    }

    return subtopics
        .map((st) => st.copyWith(
              ruleCount: ruleCounts[st.id] ?? 0,
              hasTest: testedSubtopicIds.contains(st.id),
            ))
        .toList(growable: false);
  }

  @override
  Future<GrammarLesson?> getLesson(int subtopicId) async {
    final subtopic = await _localDataSource.getSubtopic(subtopicId);
    if (subtopic == null) return null;

    // Drop the ~213 in-corpus `ADS NATIVE` placeholder rows before we spend
    // queries hydrating their descriptions/examples (they have none).
    final rules = (await _localDataSource.getRulesForSubtopic(subtopicId))
        .where((r) => !_isAdRule(r))
        .toList(growable: false);
    final hydratedRules = <GrammarRule>[];

    for (final rule in rules) {
      final descriptions = await _localDataSource.getDescriptions(rule.id);
      final hydratedDescriptions = await Future.wait(
        descriptions.map((d) async {
          final examples = await _localDataSource.getExamples(d.id);
          return d.copyWithExamples(examples);
        }),
      );
      hydratedRules.add(rule.copyWithDescriptions(hydratedDescriptions));
    }

    return GrammarLesson(subtopic: subtopic, rules: hydratedRules);
  }

  @override
  Future<List<GrammarRuleTest>> getRuleTests(int subtopicId) =>
      _localDataSource.getRuleTestsForSubtopic(subtopicId);

  /// Sentinel rule title used in the corpus to mark a native-ad placeholder.
  /// These rows have no descriptions/examples and must never reach the UI.
  static bool _isAdRule(GrammarRule rule) {
    final t = (rule.title ?? '').trim().toUpperCase();
    return t == 'ADS NATIVE';
  }
}
