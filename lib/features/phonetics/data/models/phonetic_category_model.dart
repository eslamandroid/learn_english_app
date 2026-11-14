import '../../../../core/localization/content_localizer_impl.dart';
import '../../domain/entities/phonetic_category.dart';

class PhoneticCategoryModel extends PhoneticCategory {
  const PhoneticCategoryModel({
    required super.id,
    required super.title,
    required super.titleAr,
    required super.icon,
    required super.articleCount,
  });

  factory PhoneticCategoryModel.fromMap(Map<String, Object?> map) {
    final id = map['id'] as int;
    return PhoneticCategoryModel(
      id: id,
      title: map['title'] as String,
      titleAr: ContentLocalizerImpl.instance.localize(
        sourceTable: 'phonetic',
        sourceId: id,
        field: 'title_ar',
        englishValue: map['title'] as String,
        arabicValue: map['title_ar'] as String?,
      ),
      icon: map['icon'] as String,
      articleCount: map['articles'] as int,
    );
  }
}
