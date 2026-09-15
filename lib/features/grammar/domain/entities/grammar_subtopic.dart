import 'package:equatable/equatable.dart';

class GrammarSubtopic extends Equatable {
  final int id;
  final int topicId;
  final String title;
  final String titleAr;
  final String? description;
  final String? descriptionAr;

  /// Rule count for this subtopic — populated by the repository when listing.
  final int ruleCount;

  /// Whether a topic-level/rule-level test exists for this subtopic.
  final bool hasTest;

  const GrammarSubtopic({
    required this.id,
    required this.topicId,
    required this.title,
    required this.titleAr,
    this.description,
    this.descriptionAr,
    this.ruleCount = 0,
    this.hasTest = false,
  });

  GrammarSubtopic copyWith({int? ruleCount, bool? hasTest}) => GrammarSubtopic(
        id: id,
        topicId: topicId,
        title: title,
        titleAr: titleAr,
        description: description,
        descriptionAr: descriptionAr,
        ruleCount: ruleCount ?? this.ruleCount,
        hasTest: hasTest ?? this.hasTest,
      );

  @override
  List<Object?> get props => [
        id,
        topicId,
        title,
        titleAr,
        description,
        descriptionAr,
        ruleCount,
        hasTest,
      ];
}
