import '../../domain/entities/grammar_subtopic.dart';

class GrammarSubtopicModel extends GrammarSubtopic {
  const GrammarSubtopicModel({
    required super.id,
    required super.topicId,
    required super.title,
    required super.titleAr,
    super.description,
    super.descriptionAr,
    super.ruleCount,
    super.hasTest,
  });

  // grammar_sub_topics uses camelCase: id, topicId, title, titleAr, ...
  factory GrammarSubtopicModel.fromMap(
    Map<String, Object?> map, {
    int ruleCount = 0,
    bool hasTest = false,
  }) {
    return GrammarSubtopicModel(
      id: map['id'] as int,
      topicId: map['topicId'] as int,
      title: map['title'] as String,
      titleAr: map['titleAr'] as String? ?? '',
      description: map['description'] as String?,
      descriptionAr: map['descriptionAr'] as String?,
      ruleCount: ruleCount,
      hasTest: hasTest,
    );
  }
}
