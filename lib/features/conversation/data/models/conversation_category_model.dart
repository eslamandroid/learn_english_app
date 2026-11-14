import '../../../../core/localization/content_localizer_impl.dart';
import '../../domain/entities/conversation_category.dart';

class ConversationCategoryModel extends ConversationCategory {
  const ConversationCategoryModel({
    required super.id,
    required super.title,
    required super.titleAr,
    required super.lessonCount,
  });

  factory ConversationCategoryModel.fromMap(Map<String, Object?> map) {
    final id = map['id'] as int;
    final titleEn = map['title'] as String;
    return ConversationCategoryModel(
      id: id,
      title: titleEn,
      titleAr: ContentLocalizerImpl.instance.localize(
        sourceTable: 'conversation_level',
        sourceId: id,
        field: 'titleAr',
        englishValue: titleEn,
        arabicValue: map['titleAr'] as String?,
      ),
      lessonCount: (map['itemCount'] as int?) ?? 0,
    );
  }
}
