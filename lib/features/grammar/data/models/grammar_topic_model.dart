import '../../domain/entities/grammar_topic.dart';

class GrammarTopicModel extends GrammarTopic {
  const GrammarTopicModel({
    required super.id,
    required super.title,
    required super.titleAr,
    super.description,
    super.descriptionAr,
    super.subtopicCount,
  });

  // grammar_topics uses camelCase column names: id, title, titleAr, ...
  factory GrammarTopicModel.fromMap(
    Map<String, Object?> map, {
    int subtopicCount = 0,
  }) {
    return GrammarTopicModel(
      id: map['id'] as int,
      title: map['title'] as String,
      titleAr: map['titleAr'] as String? ?? '',
      description: map['description'] as String?,
      descriptionAr: map['descriptionAr'] as String?,
      subtopicCount: subtopicCount,
    );
  }
}
