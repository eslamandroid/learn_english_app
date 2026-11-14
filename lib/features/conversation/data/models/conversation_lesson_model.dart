import '../../../../core/localization/content_localizer_impl.dart';
import '../../domain/entities/conversation_lesson.dart';

class ConversationLessonModel extends ConversationLesson {
  const ConversationLessonModel({
    required super.id,
    required super.categoryId,
    required super.title,
    required super.titleAr,
    required super.durationSeconds,
    required super.lineCount,
  });

  factory ConversationLessonModel.fromMap(Map<String, Object?> map) {
    final id = map['id'] as int;
    final titleEn = map['title'] as String;
    return ConversationLessonModel(
      id: id,
      categoryId: map['level_id'] as int,
      title: titleEn,
      titleAr: ContentLocalizerImpl.instance.localize(
        sourceTable: 'conversation_lesson',
        sourceId: id,
        field: 'titleAr',
        englishValue: titleEn,
        arabicValue: map['titleAr'] as String?,
      ),
      durationSeconds: (map['duration'] as int?) ?? 0,
      lineCount: (map['line_count'] as int?) ?? 0,
    );
  }
}
