import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/features/conversation/domain/entities/conversation_line.dart';
import 'package:learn_english_app/features/conversation/presentation/widgets/conversation_bubble.dart';
import 'package:learn_english_app/features/sentences/presentation/bloc/sentence_practice/sentence_practice_state.dart';

/// TASK 12.2 §B — during an active mic session the previous attempt's
/// "Didn't catch that" / score chip must NOT remain visible under the
/// bubble; a listening strip (with the live partial transcript) takes its
/// place.

ConversationLine _line() => const ConversationLine(
      id: 42,
      lessonId: 1,
      character: 'Alex',
      english: 'Hello there',
      phonetic: '',
      arabic: '',
    );

SentencePracticeAttempt _staleFailureAttempt() => const SentencePracticeAttempt(
      outcome: SentencePracticeOutcome.noSpeech,
      heard: '',
    );

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: child),
    );

void main() {
  group('ConversationBubble while isListening=true', () {
    testWidgets(
      'stale "Didn\'t catch that" from the previous attempt is hidden',
      (tester) async {
        await tester.pumpWidget(_host(ConversationBubble(
          line: _line(),
          alignRight: false,
          isCurrent: false,
          isUpcoming: false,
          isPlaying: false,
          attempt: _staleFailureAttempt(),
          isListening: true,
          armed: true,
          partialText: '',
          onPlay: () {},
          onMic: () {},
        )));
        await tester.pump();
        expect(
          find.text("Didn't catch that — try again."),
          findsNothing,
          reason:
              'the previous failure line must not leak into the current, '
              'active mic session',
        );
      },
    );

    testWidgets(
      'before armed → shows "Get ready…" so the user does not speak into '
      'a mic that is not live yet',
      (tester) async {
        await tester.pumpWidget(_host(ConversationBubble(
          line: _line(),
          alignRight: false,
          isCurrent: false,
          isUpcoming: false,
          isPlaying: false,
          attempt: null,
          isListening: true,
          armed: false,
          partialText: '',
          onPlay: () {},
          onMic: () {},
        )));
        await tester.pump();
        expect(find.text('Get ready…'), findsOneWidget);
      },
    );

    testWidgets(
      'armed with empty partial → shows "Listening…"; non-empty partial '
      '→ renders it as the live transcript',
      (tester) async {
        await tester.pumpWidget(_host(ConversationBubble(
          line: _line(),
          alignRight: false,
          isCurrent: false,
          isUpcoming: false,
          isPlaying: false,
          attempt: null,
          isListening: true,
          armed: true,
          partialText: '',
          onPlay: () {},
          onMic: () {},
        )));
        await tester.pump();
        expect(find.text('Listening…'), findsOneWidget);

        await tester.pumpWidget(_host(ConversationBubble(
          line: _line(),
          alignRight: false,
          isCurrent: false,
          isUpcoming: false,
          isPlaying: false,
          attempt: null,
          isListening: true,
          armed: true,
          partialText: 'hello wor',
          onPlay: () {},
          onMic: () {},
        )));
        await tester.pump();
        expect(find.text('"hello wor"'), findsOneWidget);
      },
    );
  });

  testWidgets(
    'after the session (isListening=false) the new attempt reappears — '
    'the hide is active only during listening',
    (tester) async {
      await tester.pumpWidget(_host(ConversationBubble(
        line: _line(),
        alignRight: false,
        isCurrent: false,
        isUpcoming: false,
        isPlaying: false,
        attempt: _staleFailureAttempt(),
        isListening: false,
        onPlay: () {},
        onMic: () {},
      )));
      await tester.pump();
      expect(find.text("Didn't catch that — try again."), findsOneWidget);
    },
  );
}
