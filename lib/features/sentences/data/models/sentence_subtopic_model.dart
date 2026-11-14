import '../../../../core/localization/content_localizer_impl.dart';
import '../../domain/entities/sentence_subtopic.dart';

class SentenceSubtopicModel extends SentenceSubtopic {
  const SentenceSubtopicModel({
    required super.id,
    required super.topicId,
    required super.title,
    required super.titleAr,
  });

  // sentencesSubTopic columns: topicId, subTopicId, titleEn, titleAr
  factory SentenceSubtopicModel.fromMap(Map<String, Object?> map) {
    final id = map['subTopicId'] as int;
    return SentenceSubtopicModel(
      id: id,
      topicId: map['topicId'] as int,
      title: map['titleEn'] as String,
      titleAr: ContentLocalizerImpl.instance.localize(
        sourceTable: 'sentencesSubTopic',
        sourceId: id,
        field: 'titleAr',
        englishValue: map['titleEn'] as String,
        arabicValue: map['titleAr'] as String?,
      ),
    );
  }
}
