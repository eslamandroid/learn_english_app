import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../models/grammar_rule_description_model.dart';
import '../models/grammar_rule_example_model.dart';
import '../models/grammar_rule_model.dart';
import '../models/grammar_rule_test_model.dart';
import '../models/grammar_subtopic_model.dart';
import '../models/grammar_topic_model.dart';

abstract class GrammarLocalDataSource {
  Future<List<GrammarTopicModel>> getTopics();
  Future<List<GrammarTopicModel>> getTopicsForLevel(int levelId);
  Future<List<GrammarSubtopicModel>> getSubtopics(int topicId);
  Future<GrammarSubtopicModel?> getSubtopic(int subtopicId);
  Future<List<GrammarRuleModel>> getRulesForSubtopic(int subtopicId);
  Future<List<GrammarRuleDescriptionModel>> getDescriptions(int ruleId);
  Future<List<GrammarRuleExampleModel>> getExamples(int descriptionId);
  Future<List<GrammarRuleTestModel>> getRuleTestsForSubtopic(int subtopicId);

  Future<Map<int, int>> getSubtopicCountsByTopic();
  Future<Map<int, int>> getRuleCountsBySubtopic();
}

@LazySingleton(as: GrammarLocalDataSource)
class GrammarLocalDataSourceImpl implements GrammarLocalDataSource {
  final Database _database;

  GrammarLocalDataSourceImpl(this._database);

  @override
  Future<List<GrammarTopicModel>> getTopics() async {
    final result = await _database.query('grammar_topics', orderBy: 'id ASC');
    return result.map(GrammarTopicModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<GrammarTopicModel>> getTopicsForLevel(int levelId) async {
    final result = await _database.rawQuery(
      '''
      SELECT gt.* FROM grammar_topics gt
      INNER JOIN level_grammar_topic lgt ON gt.id = lgt.topicId
      WHERE lgt.levelId = ?
      ORDER BY gt.id ASC
      ''',
      [levelId],
    );
    return result.map(GrammarTopicModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<GrammarSubtopicModel>> getSubtopics(int topicId) async {
    final result = await _database.query(
      'grammar_sub_topics',
      where: 'topicId = ?',
      whereArgs: [topicId],
      orderBy: 'id ASC',
    );
    return result.map(GrammarSubtopicModel.fromMap).toList(growable: false);
  }

  @override
  Future<GrammarSubtopicModel?> getSubtopic(int subtopicId) async {
    final result = await _database.query(
      'grammar_sub_topics',
      where: 'id = ?',
      whereArgs: [subtopicId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return GrammarSubtopicModel.fromMap(result.first);
  }

  // grammar_content.id === grammar_sub_topics.id (1:1), so we can join
  // grammar_rule.content_id directly against the subtopic id.
  @override
  Future<List<GrammarRuleModel>> getRulesForSubtopic(int subtopicId) async {
    final result = await _database.query(
      'grammar_rule',
      where: 'content_id = ?',
      whereArgs: [subtopicId],
      orderBy: 'sort_order ASC',
    );
    return result.map(GrammarRuleModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<GrammarRuleDescriptionModel>> getDescriptions(int ruleId) async {
    final result = await _database.query(
      'grammar_rule_description',
      where: 'rule_id = ?',
      whereArgs: [ruleId],
      orderBy: 'sort_order ASC',
    );
    return result
        .map(GrammarRuleDescriptionModel.fromMap)
        .toList(growable: false);
  }

  @override
  Future<List<GrammarRuleExampleModel>> getExamples(int descriptionId) async {
    final result = await _database.query(
      'grammar_rule_example',
      where: 'description_id = ?',
      whereArgs: [descriptionId],
      orderBy: 'sort_order ASC',
    );
    return result
        .map(GrammarRuleExampleModel.fromMap)
        .toList(growable: false);
  }

  @override
  Future<List<GrammarRuleTestModel>> getRuleTestsForSubtopic(
    int subtopicId,
  ) async {
    final result = await _database.rawQuery(
      '''
      SELECT t.* FROM grammar_rule_test t
      INNER JOIN grammar_rule r ON r.id = t.rule_id
      WHERE r.content_id = ?
      ORDER BY r.sort_order ASC, t.id ASC
      ''',
      [subtopicId],
    );
    return result.map(GrammarRuleTestModel.fromMap).toList(growable: false);
  }

  @override
  Future<Map<int, int>> getSubtopicCountsByTopic() async {
    final rows = await _database.rawQuery(
      'SELECT topicId, COUNT(*) c FROM grammar_sub_topics GROUP BY topicId',
    );
    return {
      for (final r in rows) (r['topicId'] as int): (r['c'] as int),
    };
  }

  @override
  Future<Map<int, int>> getRuleCountsBySubtopic() async {
    final rows = await _database.rawQuery(
      'SELECT content_id, COUNT(*) c FROM grammar_rule GROUP BY content_id',
    );
    return {
      for (final r in rows) (r['content_id'] as int): (r['c'] as int),
    };
  }
}
