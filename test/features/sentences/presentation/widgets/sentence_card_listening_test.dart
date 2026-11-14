import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/speech/sentence_assessment.dart';
import 'package:learn_english_app/core/utils/voice_preferences.dart';
import 'package:learn_english_app/features/sentences/domain/entities/sentence_item.dart';
import 'package:learn_english_app/features/sentences/presentation/bloc/sentence_practice/sentence_practice_state.dart';
import 'package:learn_english_app/features/sentences/presentation/widgets/sentence_card_large.dart';
import 'package:learn_english_app/shared/enums/playback_speed.dart';

/// TASK 12.2 §B — while the mic is live for a sentence the previous
/// RepeatResultBox ("YOU SAID · 60%") must NOT remain visible. The hint
/// line takes over and shows the live state.

SentenceItem _sentence() => const SentenceItem(
      id: 7,
      english: 'The weather is nice today.',
      arabic: 'الطقس جميل اليوم.',
    );

SentencePracticeAttempt _staleAssessedAttempt() => const SentencePracticeAttempt(
      outcome: SentencePracticeOutcome.assessed,
      heard: 'the weather',
      assessment: SentenceAssessment(
        score: 0.6,
        passed: false,
        words: [
          WordResult(word: 'the', status: WordStatus.correct),
          WordResult(word: 'weather', status: WordStatus.correct),
          WordResult(word: 'is', status: WordStatus.incorrect),
          WordResult(word: 'nice', status: WordStatus.incorrect),
          WordResult(word: 'today', status: WordStatus.incorrect),
        ],
      ),
    );

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

Widget _card({required bool isListening, SentencePracticeAttempt? attempt}) {
  return SentenceCardLarge(
    sentence: _sentence(),
    topicIconKey: null,
    isPlaying: false,
    onPlayTap: () {},
    accent: VoiceAccent.us,
    speed: PlaybackSpeed.normal,
    onAccentChanged: (_) {},
    onSpeedChanged: (_) {},
    isListening: isListening,
    armed: isListening,
    partialText: isListening ? 'the weather is' : '',
    attempt: attempt,
    onMicTap: () {},
    onTryAgain: () {},
  );
}

void main() {
  testWidgets(
    'isListening=true with a stale assessed attempt → the RepeatResultBox '
    '("YOU SAID · 60%") disappears so the user does not confuse the old '
    'score for the current take (TASK 12.2 §B)',
    (tester) async {
      await tester.pumpWidget(_host(_card(
        isListening: true,
        attempt: _staleAssessedAttempt(),
      )));
      await tester.pump();
      // "YOU SAID · 60%" is the signature RepeatResultBox header.
      expect(find.textContaining('YOU SAID'), findsNothing);
      expect(find.textContaining('60%'), findsNothing);
    },
  );

  testWidgets(
    'after the session (isListening=false) the box reappears — the hide '
    'is scoped to the active-mic window only',
    (tester) async {
      await tester.pumpWidget(_host(_card(
        isListening: false,
        attempt: _staleAssessedAttempt(),
      )));
      await tester.pump();
      expect(find.textContaining('YOU SAID'), findsOneWidget);
      expect(find.textContaining('60%'), findsOneWidget);
    },
  );
}
