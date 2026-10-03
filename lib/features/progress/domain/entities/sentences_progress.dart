import 'package:equatable/equatable.dart';

import 'sentence_lesson_progress.dart';

/// Snapshot of the user's sentences progress.
/// Mirrors [GrammarProgress] exactly — same fields, same logic.
/// Sentences subtopics are always unlocked (no sequential lock),
/// so [statusFor] never returns `locked`.
class SentencesProgress extends Equatable {
  final Set<int> completedSubtopicIds;

  /// The subtopic most recently opened but not yet completed.
  /// At most one is "in progress" at a time.
  final int? inProgressSubtopicId;

  /// Per-lesson progress, keyed by `lessonId` (== subTopicId).
  /// Powers the lesson sublist row's "9 / 16" / "Done" state.
  final Map<int, SentenceLessonProgress> lessons;

  const SentencesProgress({
    required this.completedSubtopicIds,
    this.inProgressSubtopicId,
    this.lessons = const {},
  });

  static const empty = SentencesProgress(completedSubtopicIds: {});

  bool isCompleted(int subtopicId) =>
      completedSubtopicIds.contains(subtopicId) ||
      (lessons[subtopicId]?.isCompleted ?? false);

  bool isInProgress(int subtopicId) =>
      (inProgressSubtopicId == subtopicId ||
          (lessons[subtopicId]?.isStarted ?? false)) &&
      !isCompleted(subtopicId);

  SentenceLessonProgress? lessonFor(int subtopicId) => lessons[subtopicId];

  /// (done, total) counts over the supplied subtopic ids.
  (int done, int total) topicCounts(List<int> subtopicIdsInTopic) {
    final total = subtopicIdsInTopic.length;
    final done = subtopicIdsInTopic.where(isCompleted).length;
    return (done, total);
  }

  /// Fraction (0.0..1.0) of subtopics completed within the given topic.
  double topicProgress(List<int> subtopicIdsInTopic) {
    final (done, total) = topicCounts(subtopicIdsInTopic);
    if (total == 0) return 0;
    return done / total;
  }

  /// Fraction (0.0..1.0) completed across all subtopics.
  double overallProgress(int totalSubtopicCount) {
    if (totalSubtopicCount <= 0) return 0;
    return completedSubtopicIds.length / totalSubtopicCount;
  }

  @override
  List<Object?> get props =>
      [completedSubtopicIds, inProgressSubtopicId, lessons];
}
