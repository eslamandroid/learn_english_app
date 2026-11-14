import 'package:equatable/equatable.dart';

class SentenceItem extends Equatable {
  final int id;

  /// Primary English text (`sentencesContent.sentencesEn`).
  final String english;

  /// Arabic translation — filled by [ContentLocalizer] from `sentencesAr`.
  final String arabic;

  /// Optional usage example (`sentencesContent.example`).
  final String? example;

  /// Optional suggested reply (`sentencesContent.answers`).
  /// Displayed as a non-interactive hint — NOT a quiz answer.
  final String? suggestedReply;

  const SentenceItem({
    required this.id,
    required this.english,
    required this.arabic,
    this.example,
    this.suggestedReply,
  });

  @override
  List<Object?> get props => [id, english, arabic, example, suggestedReply];
}
