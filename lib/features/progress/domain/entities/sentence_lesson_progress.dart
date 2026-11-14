import 'package:equatable/equatable.dart';

/// Per-lesson progress snapshot — row from `sentence_lesson_progress`.
/// Drives the lesson sublist display: "9 / 16" when started, full green bar
/// + Done pill when complete, nothing when not started.
class SentenceLessonProgress extends Equatable {
  final int lessonId;
  final int seen;
  final int total;
  final DateTime? completedAt;

  const SentenceLessonProgress({
    required this.lessonId,
    required this.seen,
    required this.total,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;
  bool get isStarted => seen > 0 && !isCompleted;

  @override
  List<Object?> get props => [lessonId, seen, total, completedAt];
}
