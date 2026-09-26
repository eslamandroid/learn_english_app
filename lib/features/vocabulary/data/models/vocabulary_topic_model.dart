import '../../domain/entities/vocabulary_topic.dart';

class VocabularyTopicModel extends VocabularyTopic {
  const VocabularyTopicModel({
    required super.id,
    required super.title,
    required super.titleAr,
    required super.imageResourceId,
    required super.cover,
    required super.icon,
    required super.subtopicCount,
    super.wordCount,
  });

  // vocaTopic columns: topicId, imageResourceId, ita, name, cover, icon,
  // subTopicCount.
  factory VocabularyTopicModel.fromMap(
    Map<String, Object?> map, {
    int wordCount = 0,
  }) {
    return VocabularyTopicModel(
      id: map['topicId'] as int,
      title: map['name'] as String,
      titleAr: (map['ita'] as String?) ?? '',
      imageResourceId: (map['imageResourceId'] as String?) ?? '',
      cover: (map['cover'] as String?) ?? '',
      icon: (map['icon'] as String?) ?? '',
      subtopicCount: (map['subTopicCount'] as int?) ?? 0,
      wordCount: wordCount,
    );
  }
}
