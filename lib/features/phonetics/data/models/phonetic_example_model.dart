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
    return PhoneticExampleModel(
      id: map['id'] as int,
      sectionId: map['section_id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      word: map['word'] as String,
      wordAr: map['word_ar'] as String?,
      phonetic: map['phonetic'] as String?,
    );
  }
}
