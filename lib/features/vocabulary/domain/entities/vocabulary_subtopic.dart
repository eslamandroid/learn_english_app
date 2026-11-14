import 'package:equatable/equatable.dart';

class VocabularySubtopic extends Equatable {
  final int id;
  final int topicId;
  final String title;
  final String titleAr;
  final String imageResourceId;

  /// Number of words in this subtopic — populated by the repository when
  /// listing, so the UI can render "N words" without fetching the words yet.
  final int wordCount;

  const VocabularySubtopic({
    required this.id,
    required this.topicId,
    required this.title,
    required this.titleAr,
    required this.imageResourceId,
    this.wordCount = 0,
  });

  VocabularySubtopic copyWith({int? wordCount}) => VocabularySubtopic(
        id: id,
        topicId: topicId,
        title: title,
        titleAr: titleAr,
        imageResourceId: imageResourceId,
        wordCount: wordCount ?? this.wordCount,
      );

  @override
  List<Object?> get props =>
      [id, topicId, title, titleAr, imageResourceId, wordCount];
}
