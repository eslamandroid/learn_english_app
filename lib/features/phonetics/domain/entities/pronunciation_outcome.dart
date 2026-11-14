enum PronunciationOutcome { correct, incorrect, noSpeech, denied, unavailable }

/// Result of one pronunciation attempt for a single example word.
class PronunciationAttempt {
  final PronunciationOutcome outcome;
  final String heard;

  /// Absolute path to the user's recorded take for this attempt. Null when
  /// the parallel recorder couldn't start (permission, platform, non-fatal
  /// failure) — see TASK 12 §3.
  final String? recordingPath;

  const PronunciationAttempt({
    required this.outcome,
    required this.heard,
    this.recordingPath,
  });

  bool get isCorrect => outcome == PronunciationOutcome.correct;
}
