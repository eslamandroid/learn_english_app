import '../../../../core/localization/content_localizer_impl.dart';
import '../../domain/entities/phonetic_example.dart';

class PhoneticExampleModel extends PhoneticExample {
  const PhoneticExampleModel({
    required super.id,
    required super.sectionId,
    required super.sortOrder,
    required super.word,
    super.wordAr,
    super.phonetic,
  });

  factory PhoneticExampleModel.fromMap(Map<String, Object?> map) {
    final id = map['id'] as int;
    return PhoneticExampleModel(
      id: id,
      sectionId: map['section_id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      word: map['word'] as String,
      // Nullable: preserve null when no Arabic value exists in DB.
      wordAr: map['word_ar'] == null
          ? null
          : ContentLocalizerImpl.instance.localize(
              sourceTable: 'phonetic_example',
              sourceId: id,
              field: 'word_ar',
              englishValue: map['word'] as String,
              arabicValue: map['word_ar'] as String?,
            ),
      phonetic: map['phonetic'] as String?,
    );
  }
}
