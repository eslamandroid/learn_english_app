enum WordStatus { correct, incorrect }

/// One target word's grading result, in the order it appears in the script.
class WordResult {
  final String word;
  final WordStatus status;

  const WordResult({required this.word, required this.status});

  bool get isCorrect => status == WordStatus.correct;
}

/// Result of grading one spoken attempt at a full sentence against its
/// script line.
class SentenceAssessment {
  /// Weighted 0.0–1.0 score. Content words count more than function words
  /// (the/a/is/...), since dropping a filler word is a much smaller miss
  /// than dropping the sentence's actual verb or noun.
  final double score;

  /// True when [score] clears the pass threshold used to compute it.
  final bool passed;

  /// Every target word with its correct/incorrect verdict, in script order.
  final List<WordResult> words;

  const SentenceAssessment({
    required this.score,
    required this.passed,
    required this.words,
  });

  /// The specific words the user should redo — feed these back into the
  /// single-word pronunciation flow so practice stays targeted instead of
  /// making them repeat the whole sentence blindly.
  List<String> get wordsToRetry =>
      words.where((w) => !w.isCorrect).map((w) => w.word).toList();
}
