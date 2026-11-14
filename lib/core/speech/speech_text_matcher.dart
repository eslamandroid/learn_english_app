/// Compares recognized speech against an expected word or short phrase.
///
/// Tolerant of casing, punctuation, and the engine returning extra
/// surrounding words (e.g. "the cat" when the target was just "cat").
class SpeechTextMatcher {
  const SpeechTextMatcher._();

  static bool matches(String heard, String target) {
    final h = _normalize(heard);
    final t = _normalize(target);
    if (t.isEmpty || h.isEmpty) return false;
    if (h == t) return true;

    final words = h.split(RegExp(r'\s+'));
    return words.contains(t) || h.contains(t);
  }

  static String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').trim();
}
