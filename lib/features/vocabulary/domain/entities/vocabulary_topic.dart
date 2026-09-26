import 'package:equatable/equatable.dart';

class VocabularyTopic extends Equatable {
  final int id;
  final String title;
  final String titleAr;
  final String imageResourceId;
  final String cover;
  final String icon;
  final int subtopicCount;

  /// Total words across all subtopics of this topic — populated by the
  /// repository when listing so the grid can render "N Words" without an
  /// N+1 fetch per topic.
  final int wordCount;

  const VocabularyTopic({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.imageResourceId,
    required this.cover,
    required this.icon,
    required this.subtopicCount,
    this.wordCount = 0,
  });

  VocabularyTopic copyWith({int? wordCount}) => VocabularyTopic(
        id: id,
        title: title,
        titleAr: titleAr,
        imageResourceId: imageResourceId,
        cover: cover,
        icon: icon,
        subtopicCount: subtopicCount,
        wordCount: wordCount ?? this.wordCount,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        titleAr,
        imageResourceId,
        cover,
        icon,
        subtopicCount,
        wordCount,
      ];
}
