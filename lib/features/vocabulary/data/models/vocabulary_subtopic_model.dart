import '../../domain/entities/vocabulary_subtopic.dart';

class VocabularySubtopicModel extends VocabularySubtopic {
  const VocabularySubtopicModel({
    required super.id,
    required super.topicId,
    required super.title,
    required super.titleAr,
    required super.imageResourceId,
    super.wordCount,
  });

  // vocaSubTopic columns: id, topicId, imageResourceId, ita, name.
  factory VocabularySubtopicModel.fromMap(
    Map<String, Object?> map, {
    int wordCount = 0,
  }) {
    return VocabularySubtopicModel(
      id: map['id'] as int,
      topicId: map['topicId'] as int,
      title: map['name'] as String,
      titleAr: (map['ita'] as String?) ?? '',
      imageResourceId: (map['imageResourceId'] as String?) ?? '',
      wordCount: wordCount,
    );
  }
}
