import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/utils/phonetic_parser.dart';

void main() {
  group('PhoneticParser.extractPhonetic — literal cases from TASK 10 §1c', () {
    test('multi-word question with final punctuation', () {
      expect(
        PhoneticParser.extractPhonetic(
          '{How | haʊ} {are | ɑː} {you | juː}?',
        ),
        'haʊ ɑː juː?',
      );
    });

    test('single word with trailing period', () {
      expect(
        PhoneticParser.extractPhonetic('{Hello | həˈloʊ}.'),
        'həˈloʊ.',
      );
    });
  });

  group('PhoneticParser.extractPhonetic — real DB samples', () {
    test('Hi.', () {
      expect(PhoneticParser.extractPhonetic('{Hi | haɪ}.'), 'haɪ.');
    });

    test("I'm good. How are you?", () {
      expect(
        PhoneticParser.extractPhonetic(
          "{I'm | aɪm} {good | gʊd}. {How | haʊ} {are | ər} {you | ju}?",
        ),
        'aɪm gʊd. haʊ ər ju?',
      );
    });

    // Real row contains a stray `.` *inside* the first brace plus the usual
    // period outside — the parser preserves both verbatim (content fidelity:
    // we don't rewrite content.db, and the odd input mirrors what ships).
    test('Do you speak English? (stray period inside first block)', () {
      expect(
        PhoneticParser.extractPhonetic(
          '{Good | gʊd.}. {Do | dʊ} {you | ju} {speak | spiːk} {English | ˈɪŋglɪʃ}?',
        ),
        'gʊd.. dʊ ju spiːk ˈɪŋglɪʃ?',
      );
    });
  });

  group('PhoneticParser.extractPhonetic — edge cases', () {
    test('empty input returns empty', () {
      expect(PhoneticParser.extractPhonetic(''), '');
    });

    test('no braces at all → returns string unchanged', () {
      expect(
        PhoneticParser.extractPhonetic('plain text no braces'),
        'plain text no braces',
      );
    });

    test('only punctuation outside the single brace block', () {
      expect(PhoneticParser.extractPhonetic('{word | wɜrd}!!'), 'wɜrd!!');
    });
  });
}
