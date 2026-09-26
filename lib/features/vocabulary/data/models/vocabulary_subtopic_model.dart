import '../../../../core/localization/content_localizer_impl.dart';
import '../../domain/entities/vocabulary_subtopic.dart';

class VocabularySubtopicModel extends VocabularySubtopic {
  const VocabularySubtopicModel({
    required super.id,
    required super.topicId,
    required super.title,
    required super.titleAr,
    required super.imageResourceId,
    super.wordCount,
  });

  // vocaSubTopic columns: id, topicId, imageResourceId, ita, name.
  factory VocabularySubtopicModel.fromMap(
    Map<String, Object?> map, {
    int wordCount = 0,
  }) {
    final id = map['id'] as int;
    return VocabularySubtopicModel(
      id: id,
      topicId: map['topicId'] as int,
      title: map['name'] as String,
      titleAr: ContentLocalizerImpl.instance.localize(
        sourceTable: 'vocaSubTopic',
        sourceId: id,
        field: 'ita',
        englishValue: map['name'] as String,
        arabicValue: map['ita'] as String?,
      ),
      imageResourceId: (map['imageResourceId'] as String?) ?? '',
      wordCount: wordCount,
    );
  }
}
