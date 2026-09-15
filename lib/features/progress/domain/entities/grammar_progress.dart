import 'package:equatable/equatable.dart';

import 'grammar_subtopic_status.dart';

/// Snapshot of the user's grammar progress across all topics/subtopics.
/// Read from local prefs; mutated through the progress repository.
class GrammarProgress extends Equatable {
  final Set<int> completedSubtopicIds;

  /// The subtopic the user most recently opened but hasn't completed.
  /// At most one is "in progress" at a time — opening a different lesson
  /// flips this id.
  final int? inProgressSubtopicId;

  const GrammarProgress({
    required this.completedSubtopicIds,
    this.inProgressSubtopicId,
  });

  static const empty = GrammarProgress(completedSubtopicIds: {});

  bool isCompleted(int subtopicId) =>
      completedSubtopicIds.contains(subtopicId);

  bool isInProgress(int subtopicId) =>
      inProgressSubtopicId == subtopicId &&
      !completedSubtopicIds.contains(subtopicId);

  /// Resolves the lock/in-progress/completed status of [subtopicId] given the
  /// ordered list of every subtopic id in its topic. The first subtopic is
  /// always unlocked; every subsequent subtopic unlocks when the previous
  /// one is completed.
  GrammarSubtopicStatus statusFor(
    int subtopicId,
    List<int> subtopicsInTopicOrder,
  ) {
    if (isCompleted(subtopicId)) return GrammarSubtopicStatus.completed;
    if (isInProgress(subtopicId)) return GrammarSubtopicStatus.inProgress;

    final i = subtopicsInTopicOrder.indexOf(subtopicId);
    if (i <= 0) return GrammarSubtopicStatus.notStarted;
    final previousId = subtopicsInTopicOrder[i - 1];
    return isCompleted(previousId)
        ? GrammarSubtopicStatus.notStarted
        : GrammarSubtopicStatus.locked;
  }

  /// Fraction (0.0 .. 1.0) of subtopics completed within the given topic.
  double topicProgress(List<int> subtopicIdsInTopic) {
    if (subtopicIdsInTopic.isEmpty) return 0;
    final done =
        subtopicIdsInTopic.where(completedSubtopicIds.contains).length;
    return done / subtopicIdsInTopic.length;
  }

  /// Fraction (0.0 .. 1.0) of subtopics completed across every topic.
  double overallProgress(int totalSubtopicCount) {
    if (totalSubtopicCount <= 0) return 0;
    return completedSubtopicIds.length / totalSubtopicCount;
  }

  @override
  List<Object?> get props => [completedSubtopicIds, inProgressSubtopicId];
}
