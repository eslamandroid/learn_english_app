import 'package:equatable/equatable.dart';

/// Snapshot of the user's conversation-lesson progress.
/// Mirrors [SentencesProgress] exactly (no sequential lock — every lesson is
/// always unlocked, per TASK 10 §9 which copies the Sentences decision).
class ConversationProgress extends Equatable {
  final Set<int> completedLessonIds;

  /// The lesson most recently opened but not yet completed. At most one is
  /// "in progress" at a time.
  final int? inProgressLessonId;

  const ConversationProgress({
    required this.completedLessonIds,
    this.inProgressLessonId,
  });

  static const empty = ConversationProgress(completedLessonIds: {});

  bool isCompleted(int lessonId) => completedLessonIds.contains(lessonId);

  bool isInProgress(int lessonId) =>
      inProgressLessonId == lessonId && !isCompleted(lessonId);

  /// (done, total) counts over the supplied lesson ids.
  (int done, int total) categoryCounts(List<int> lessonIds) {
    final total = lessonIds.length;
    final done = lessonIds.where(isCompleted).length;
    return (done, total);
  }

  double categoryProgress(List<int> lessonIds) {
    final (done, total) = categoryCounts(lessonIds);
    if (total == 0) return 0;
    return done / total;
  }

  @override
  List<Object?> get props => [completedLessonIds, inProgressLessonId];
}
