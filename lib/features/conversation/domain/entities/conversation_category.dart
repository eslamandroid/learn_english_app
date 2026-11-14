import 'package:equatable/equatable.dart';

/// One row of `conversation_level` — a top-level grouping of lessons
/// (14 rows, e.g. "General Questions", "Simple Needs").
///
/// Note: the DB column `conversation_level.level` (1..3) is intentionally
/// NOT exposed here. Per TASK 10 §1a it has no defined meaning in the UI
/// and is unrelated to CEFR levels.
class ConversationCategory extends Equatable {
  final int id;
  final String title;
  final String titleAr;
  final int lessonCount;

  const ConversationCategory({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.lessonCount,
  });

  @override
  List<Object?> get props => [id, title, titleAr, lessonCount];
}
