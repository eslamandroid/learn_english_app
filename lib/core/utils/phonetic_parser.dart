/// Converts `conversation_sentence.phonetic`'s raw inline-notation format
/// into a displayable IPA-only string.
///
/// The DB stores each word paired with its pronunciation inside braces,
/// punctuation lives outside the braces:
///   `"{How | haʊ} {are | ɑː} {you | juː}?"` → `"haʊ ɑː juː?"`
///   `"{Hello | həˈloʊ}."`                   → `"həˈloʊ."`
///
/// The regex captures the right-hand side of each `{word | ipa}` block and
/// swaps the whole block for just the IPA, leaving anything *between* the
/// blocks (punctuation, spaces) untouched. See [TASK 10 §1c].
abstract class PhoneticParser {
  // `[^|]+` matches the English word part; `\s*` skips the pipe gap; `([^}]+)`
  // captures everything up to the closing brace (including any inner spaces
  // in multi-glyph IPA transcriptions like `həˈloʊ`).
  static final RegExp _blockPattern =
      RegExp(r'\{\s*[^|]+\|\s*([^}]+)\}');

  /// Returns the IPA-only transcription for display. If [raw] contains no
  /// `{…|…}` blocks (bad/legacy row), the string is returned unchanged.
  static String extractPhonetic(String raw) {
    if (raw.isEmpty) return raw;
    return raw.replaceAllMapped(
      _blockPattern,
      (m) => (m.group(1) ?? '').trim(),
    );
  }
}
