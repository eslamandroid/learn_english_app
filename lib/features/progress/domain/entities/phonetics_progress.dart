import 'package:equatable/equatable.dart';

import 'grammar_subtopic_status.dart';

/// Snapshot of the user's phonetics progress. Topics within a category unlock
/// sequentially — the first topic in each category is always unlocked, the
/// next unlocks when the previous one is marked complete.
///
/// We reuse [GrammarSubtopicStatus] as the universal lock/in-progress/done
/// state — it's purely descriptive and module-agnostic.
class PhoneticsProgress extends Equatable {
  final Set<int> completedTopicIds;
  final int? inProgressTopicId;

  const PhoneticsProgress({
    required this.completedTopicIds,
    this.inProgressTopicId,
  });

  static const empty = PhoneticsProgress(completedTopicIds: {});

  bool isCompleted(int topicId) => completedTopicIds.contains(topicId);

  bool isInProgress(int topicId) =>
      inProgressTopicId == topicId && !completedTopicIds.contains(topicId);

  /// Status of [topicId] given the ordered list of every topic id inside the
  /// same category. First topic of every category is always unlocked.
  GrammarSubtopicStatus statusFor(
    int topicId,
    List<int> topicsInCategoryOrder,
  ) {
    if (isCompleted(topicId)) return GrammarSubtopicStatus.completed;
    if (isInProgress(topicId)) return GrammarSubtopicStatus.inProgress;

    final i = topicsInCategoryOrder.indexOf(topicId);
    if (i <= 0) return GrammarSubtopicStatus.notStarted;
    final prev = topicsInCategoryOrder[i - 1];
    return isCompleted(prev)
        ? GrammarSubtopicStatus.notStarted
        : GrammarSubtopicStatus.locked;
  }

  /// % of topics completed inside a single category.
  double categoryProgress(List<int> topicIdsInCategory) {
    if (topicIdsInCategory.isEmpty) return 0;
    final done = topicIdsInCategory.where(completedTopicIds.contains).length;
    return done / topicIdsInCategory.length;
  }

  /// % across every phonetic topic in the corpus.
  double overallProgress(int totalTopicCount) {
    if (totalTopicCount <= 0) return 0;
    return completedTopicIds.length / totalTopicCount;
  }

  @override
  List<Object?> get props => [completedTopicIds, inProgressTopicId];
}
