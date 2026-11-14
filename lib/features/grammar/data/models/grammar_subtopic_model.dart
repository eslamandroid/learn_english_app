import '../../../../core/localization/content_localizer_impl.dart';
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
    final id = map['id'] as int;
    return GrammarSubtopicModel(
      id: id,
      topicId: map['topicId'] as int,
      title: map['title'] as String,
      titleAr: ContentLocalizerImpl.instance.localize(
        sourceTable: 'grammar_sub_topics',
        sourceId: id,
        field: 'titleAr',
        englishValue: map['title'] as String,
        arabicValue: map['titleAr'] as String?,
      ),
      description: map['description'] as String?,
      descriptionAr: map['descriptionAr'] == null
          ? null
          : ContentLocalizerImpl.instance.localize(
              sourceTable: 'grammar_sub_topics',
              sourceId: id,
              field: 'descriptionAr',
              englishValue: map['description'] as String? ?? '',
              arabicValue: map['descriptionAr'] as String?,
            ),
      ruleCount: ruleCount,
      hasTest: hasTest,
    );
  }
}
