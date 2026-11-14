import '../../../../core/localization/content_localizer_impl.dart';
import '../../domain/entities/sentence_item.dart';

class SentenceItemModel extends SentenceItem {
  const SentenceItemModel({
    required super.id,
    required super.english,
    required super.arabic,
    super.example,
    super.suggestedReply,
  });

  // sentencesContent columns: id, subTopicId, sentencesGrammarEn, sentencesEn,
  //   sentencesAr, example, sentenceTitleEn, answers
  factory SentenceItemModel.fromMap(Map<String, Object?> map) {
    final id = map['id'] as int;
    final english = map['sentencesEn'] as String? ?? '';
    return SentenceItemModel(
      id: id,
      english: english,
      arabic: ContentLocalizerImpl.instance.localize(
        sourceTable: 'sentencesContent',
        sourceId: id,
        field: 'sentencesAr',
        englishValue: english,
        arabicValue: map['sentencesAr'] as String?,
      ),
      example: _emptyToNull(map['example'] as String?),
      suggestedReply: _emptyToNull(map['answers'] as String?),
    );
  }

  static String? _emptyToNull(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();
}
