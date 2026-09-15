import 'package:equatable/equatable.dart';

class GrammarTopic extends Equatable {
  final int id;
  final String title;
  final String titleAr;
  final String? description;
  final String? descriptionAr;

  /// Subtopic count for this topic — populated by the repository when listing.
  final int subtopicCount;

  const GrammarTopic({
    required this.id,
    required this.title,
    required this.titleAr,
    this.description,
    this.descriptionAr,
    this.subtopicCount = 0,
  });

  GrammarTopic withSubtopicCount(int count) => GrammarTopic(
        id: id,
        title: title,
        titleAr: titleAr,
        description: description,
        descriptionAr: descriptionAr,
        subtopicCount: count,
      );

  @override
  List<Object?> get props =>
      [id, title, titleAr, description, descriptionAr, subtopicCount];
}
