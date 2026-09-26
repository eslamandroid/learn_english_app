enum PronunciationOutcome { correct, incorrect, noSpeech, denied, unavailable }

/// Result of one pronunciation attempt for a single example word.
class PronunciationAttempt {
  final PronunciationOutcome outcome;
  final String heard;

  const PronunciationAttempt({required this.outcome, required this.heard});

  bool get isCorrect => outcome == PronunciationOutcome.correct;
}
