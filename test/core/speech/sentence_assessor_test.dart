import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/speech/sentence_assessor.dart';
import 'package:learn_english_app/core/speech/sentence_assessment.dart';

void main() {
  // ── Exact match ────────────────────────────────────────────────────────────

  test('exact match → score 1.0 and passed', () {
    final result = SentenceAssessor.assess('Hi there', 'Hi there');
    expect(result.score, 1.0);
    expect(result.passed, isTrue);
    expect(result.words.every((w) => w.isCorrect), isTrue);
  });

  test('exact match case-insensitive → score 1.0', () {
    final result = SentenceAssessor.assess('HI THERE', 'hi there');
    expect(result.score, 1.0);
  });

  // ── Empty input ────────────────────────────────────────────────────────────

  test('empty heard → score 0.0 and not passed', () {
    final result = SentenceAssessor.assess('', 'Hi there');
    expect(result.score, 0.0);
    expect(result.passed, isFalse);
    expect(result.words.every((w) => !w.isCorrect), isTrue);
  });

  test('empty target → score 0.0 and not passed', () {
    final result = SentenceAssessor.assess('Hi there', '');
    expect(result.score, 0.0);
    expect(result.passed, isFalse);
  });

  // ── Function-word vs content-word weight ──────────────────────────────────

  test('missing function word lowers score less than missing content word', () {
    // "a" is a function word — dropping it costs 0.4 weight.
    final missingFunction = SentenceAssessor.assess(
      'buy car',
      'buy a car',
    );

    // "car" is a content word — dropping it costs 1.0 weight.
    final missingContent = SentenceAssessor.assess(
      'buy a',
      'buy a car',
    );

    expect(missingFunction.score, greaterThan(missingContent.score),
        reason:
            'dropping a function word ("a") should penalise less than '
            'dropping a content word ("car")');
  });

  // ── Partial match ──────────────────────────────────────────────────────────

  test('single wrong word lowers score but sentence can still pass threshold', () {
    // 4 correct words out of 5 → should still pass if the missed word has low
    // weight (function word).
    final result = SentenceAssessor.assess(
      'What your name',  // missing "is" (function word)
      'What is your name',
    );
    // "is" is in function words; score should be relatively high.
    expect(result.score, greaterThan(0.7));
    expect(result.words.length, 4); // 4 target words
  });

  test('multiple wrong words → not passed', () {
    final result = SentenceAssessor.assess(
      'hello world',
      'Good morning everyone how are you',
    );
    expect(result.passed, isFalse);
  });

  // ── Word-level results ─────────────────────────────────────────────────────

  test('each target word has a WordResult in script order', () {
    final result = SentenceAssessor.assess('Hi there', 'Hi there');
    expect(result.words.map((w) => w.word).toList(), ['hi', 'there']);
    expect(result.words[0].status, WordStatus.correct);
    expect(result.words[1].status, WordStatus.correct);
  });

  test('incorrect word is flagged in wordsToRetry', () {
    // "morning" is present but "hello" is replaced by something else.
    final result = SentenceAssessor.assess('good evening', 'good morning');
    expect(result.wordsToRetry, contains('morning'));
  });

  // ── Recognizer noise tolerance ─────────────────────────────────────────────

  test('minor spelling difference treated as correct ("talkin" vs "talking")', () {
    final result = SentenceAssessor.assess('I am talkin', 'I am talking');
    // "talkin" vs "talking" — within 1/3-char tolerance → should be correct.
    expect(result.words.last.isCorrect, isTrue);
  });

  // ── Different word order ───────────────────────────────────────────────────

  test('completely reversed word order — behaviour documented (alignment-based)', () {
    // The assessor uses edit-distance alignment, not a bag-of-words match.
    // "world hello" vs "hello world": both words exist but in wrong order,
    // so alignment treats one as substituted and gives a lower score than exact.
    // Document the actual behaviour here rather than assuming a specific value.
    final result = SentenceAssessor.assess('world hello', 'hello world');
    // We only assert it doesn't crash and returns sensible types.
    expect(result.score, inInclusiveRange(0.0, 1.0));
    expect(result.words.length, 2);
    // Score is likely < 1.0 because alignment does not reorder.
    expect(result.score, lessThan(1.0));
  });
}
