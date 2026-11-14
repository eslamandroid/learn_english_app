import '../../../../core/localization/content_localizer_impl.dart';
import '../../domain/entities/sentence_topic.dart';

class SentenceTopicModel extends SentenceTopic {
  const SentenceTopicModel({
    required super.id,
    required super.title,
    required super.titleAr,
    required super.sentenceCount,
    super.icon,
  });

  // sentenceTopic columns: topicId, titleEn, titleAr, count, icon
  factory SentenceTopicModel.fromMap(Map<String, Object?> map) {
    final id = map['topicId'] as int;
    return SentenceTopicModel(
      id: id,
      title: map['titleEn'] as String,
      titleAr: ContentLocalizerImpl.instance.localize(
        sourceTable: 'sentenceTopic',
        sourceId: id,
        field: 'titleAr',
        englishValue: map['titleEn'] as String,
        arabicValue: map['titleAr'] as String?,
      ),
      sentenceCount: map['count'] as int? ?? 0,
      icon: map['icon'] as String?,
    );
  }
}
