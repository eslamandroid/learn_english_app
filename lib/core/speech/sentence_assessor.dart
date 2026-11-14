import 'sentence_assessment.dart';

/// Grades a heard transcript against a scripted target sentence.
///
/// Why not just compare full strings? Recognizers routinely drop short
/// function words ("a", "is", "to") even when they were spoken clearly —
/// see [SpeechRecognitionService] docs for why. A strict full-string
/// comparison would fail sentences that were actually pronounced correctly.
/// Instead this aligns the two word sequences (word-level edit distance,
/// like a diff) so:
/// - a genuinely missing/garbled word is caught and named
/// - minor recognizer noise on individual words (e.g. "talkin" for
///   "talking") doesn't count against the user
/// - dropping "the" costs less than dropping the sentence's main verb
///
/// Pure algorithm, no plugin or Flutter dependency — usable for any
/// scripted-sentence check, not just the conversation feature.
class SentenceAssessor {
  const SentenceAssessor._();

  static const double defaultPassThreshold = 0.75;

  /// Common English function words — weighted lower, since a recognizer
  /// dropping one of these is noise, not a pronunciation miss.
  static const Set<String> _functionWords = {
    'a', 'an', 'the', 'is', 'are', 'was', 'were', 'am', 'be', 'been',
    'to', 'of', 'in', 'on', 'at', 'for', 'and', 'but', 'or', 'so',
    'it', 'its', "it's", 'do', 'does', 'did', 'has', 'have', 'had',
    'i', 'you', 'he', 'she', 'we', 'they', 'my', 'your', 'his', 'her',
    'this', 'that', 'with', 'as', 'up',
  };

  static SentenceAssessment assess(
    String heard,
    String target, {
    double passThreshold = defaultPassThreshold,
  }) {
    final targetWords = _tokenize(target);
    final heardWords = _tokenize(heard);

    if (targetWords.isEmpty) {
      return const SentenceAssessment(score: 0, passed: false, words: []);
    }

    final matches = _alignExactMatches(targetWords, heardWords);

    var weightedCorrect = 0.0;
    var weightedTotal = 0.0;
    final results = <WordResult>[];

    for (var i = 0; i < targetWords.length; i++) {
      final word = targetWords[i];
      final weight = _functionWords.contains(word) ? 0.4 : 1.0;
      final isCorrect = matches[i];

      weightedTotal += weight;
      if (isCorrect) weightedCorrect += weight;

      results.add(WordResult(
        word: word,
        status: isCorrect ? WordStatus.correct : WordStatus.incorrect,
      ));
    }

    final score = weightedTotal == 0 ? 0.0 : weightedCorrect / weightedTotal;
    return SentenceAssessment(
      score: score,
      passed: score >= passThreshold,
      words: results,
    );
  }

  /// Word-level Levenshtein alignment between [target] and [heard].
  /// Returns, per target-word index, whether it has a matching (identical
  /// or near-identical) counterpart somewhere in the aligned heard sequence.
  ///
  /// Substitution cost is 0 when the two words are near-identical
  /// (tolerates small recognizer spelling noise), 1 otherwise. Standard
  /// insert/delete cost of 1. This is the same idea as a text diff, just
  /// scored per-word instead of per-character.
  static List<bool> _alignExactMatches(
    List<String> target,
    List<String> heard,
  ) {
    final n = target.length;
    final m = heard.length;

    // dp[i][j] = min edit cost aligning target[0..i) with heard[0..j)
    final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
    for (var i = 0; i <= n; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= m; j++) {
      dp[0][j] = j;
    }

    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= m; j++) {
        final subCost = _wordsSimilar(target[i - 1], heard[j - 1]) ? 0 : 1;
        final sub = dp[i - 1][j - 1] + subCost;
        final del = dp[i - 1][j] + 1; // target word missing from heard
        final ins = dp[i][j - 1] + 1; // extra word in heard, ignored
        dp[i][j] = [sub, del, ins].reduce((a, b) => a < b ? a : b);
      }
    }

    // Backtrack to find, for each target index, whether it landed on a
    // zero-cost substitution (a match) or a delete/mismatched substitution
    // (a miss).
    final matched = List<bool>.filled(n, false);
    var i = n, j = m;
    while (i > 0 && j > 0) {
      final subCost = _wordsSimilar(target[i - 1], heard[j - 1]) ? 0 : 1;
      if (dp[i][j] == dp[i - 1][j - 1] + subCost) {
        matched[i - 1] = subCost == 0;
        i--;
        j--;
      } else if (dp[i][j] == dp[i - 1][j] + 1) {
        matched[i - 1] = false; // missing
        i--;
      } else {
        j--; // extra heard word — doesn't correspond to any target word
      }
    }
    while (i > 0) {
      matched[i - 1] = false;
      i--;
    }

    return matched;
  }

  /// True when two words are close enough to count as the same word once
  /// minor recognizer noise is accounted for — roughly a 1-in-3-characters
  /// tolerance. Catches things like "talkin" for "talking" or a dropped
  /// trailing "s", while staying tight enough that genuinely different
  /// words ("cat" vs "hat", "there" vs "their") still count as a miss.
  static bool _wordsSimilar(String a, String b) {
    if (a == b) return true;
    final maxLen = a.length > b.length ? a.length : b.length;
    if (maxLen == 0) return true;
    final tolerance = (maxLen / 3).floor().clamp(1, 4);
    return _levenshtein(a, b) <= tolerance;
  }

  static int _levenshtein(String a, String b) {
    final n = a.length, m = b.length;
    if (n == 0) return m;
    if (m == 0) return n;

    var prev = List<int>.generate(m + 1, (j) => j);
    var curr = List<int>.filled(m + 1, 0);

    for (var i = 1; i <= n; i++) {
      curr[0] = i;
      for (var j = 1; j <= m; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [
          prev[j] + 1,
          curr[j - 1] + 1,
          prev[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[m];
  }

  static List<String> _tokenize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9'\s]"), '')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
}
