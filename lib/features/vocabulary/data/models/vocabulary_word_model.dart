import '../../domain/entities/vocabulary_word.dart';

class VocabularyWordModel extends VocabularyWord {
  const VocabularyWordModel({
    required super.id,
    required super.subtopicId,
    required super.word,
    required super.wordAr,
    required super.description,
    required super.imageResourceId,
    required super.sound,
    required super.phonetic,
    required super.usage,
  });

  // vocabulary columns: id, subTopicId, ita, name, desc, imageResourceId,
  // sound, trans, usage.
  factory VocabularyWordModel.fromMap(Map<String, Object?> map) {
    return VocabularyWordModel(
      id: map['id'] as int,
      subtopicId: map['subTopicId'] as int,
      word: map['name'] as String,
      wordAr: (map['ita'] as String?) ?? '',
      description: (map['desc'] as String?) ?? '',
      imageResourceId: (map['imageResourceId'] as String?) ?? '',
      sound: (map['sound'] as String?) ?? '',
      phonetic: (map['trans'] as String?) ?? '',
      usage: (map['usage'] as String?) ?? '',
    );
  }
}
