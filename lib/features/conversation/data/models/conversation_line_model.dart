import '../../../../core/localization/content_localizer_impl.dart';
import '../../../../core/utils/phonetic_parser.dart';
import '../../domain/entities/conversation_line.dart';

class ConversationLineModel extends ConversationLine {
  const ConversationLineModel({
    required super.id,
    required super.lessonId,
    required super.character,
    required super.english,
    required super.phonetic,
    required super.arabic,
  });

  factory ConversationLineModel.fromMap(Map<String, Object?> map) {
    final id = map['id'] as int;
    final english = (map['sentence'] as String?) ?? '';
    return ConversationLineModel(
      id: id,
      lessonId: map['lesson'] as int,
      character: (map['character'] as String?) ?? '',
      english: english,
      phonetic:
          PhoneticParser.extractPhonetic((map['phonetic'] as String?) ?? ''),
      arabic: ContentLocalizerImpl.instance.localize(
        sourceTable: 'conversation_sentence',
        sourceId: id,
        field: 'sentenceAr',
        englishValue: english,
        arabicValue: map['sentenceAr'] as String?,
      ),
    );
  }
}
