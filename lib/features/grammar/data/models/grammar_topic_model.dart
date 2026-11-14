import '../../../../core/localization/content_localizer_impl.dart';
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
    final id = map['id'] as int;
    return GrammarTopicModel(
      id: id,
      title: map['title'] as String,
      titleAr: ContentLocalizerImpl.instance.localize(
        sourceTable: 'grammar_topics',
        sourceId: id,
        field: 'titleAr',
        englishValue: map['title'] as String,
        arabicValue: map['titleAr'] as String?,
      ),
      description: map['description'] as String?,
      descriptionAr: map['descriptionAr'] == null
          ? null
          : ContentLocalizerImpl.instance.localize(
              sourceTable: 'grammar_topics',
              sourceId: id,
              field: 'descriptionAr',
              englishValue: map['description'] as String? ?? '',
              arabicValue: map['descriptionAr'] as String?,
            ),
      subtopicCount: subtopicCount,
    );
  }
}
