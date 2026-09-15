/// Status of a single grammar subtopic ("lesson") from the user's perspective.
enum GrammarSubtopicStatus {
  /// The user can't open this lesson yet — previous lesson in the topic
  /// isn't completed.
  locked,

  /// Unlocked but never opened.
  notStarted,

  /// Opened at least once but not finished.
  inProgress,

  /// Finished — `Finish Lesson` was tapped in the lesson screen.
  completed;

  bool get isLocked => this == GrammarSubtopicStatus.locked;
  bool get isCompleted => this == GrammarSubtopicStatus.completed;
  bool get isInProgress => this == GrammarSubtopicStatus.inProgress;
}
