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
    return PhoneticCategoryModel(
      id: map['id'] as int,
      title: map['title'] as String,
      titleAr: map['title_ar'] as String,
      icon: map['icon'] as String,
      articleCount: map['articles'] as int,
    );
  }
}
