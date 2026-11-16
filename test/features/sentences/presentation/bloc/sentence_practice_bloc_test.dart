import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/speech/speech_models.dart';
import 'package:learn_english_app/core/speech/speech_recognition_service.dart';
import 'package:learn_english_app/features/sentences/presentation/bloc/sentence_practice/sentence_practice_bloc.dart';
import 'package:learn_english_app/features/sentences/presentation/bloc/sentence_practice/sentence_practice_event.dart';
import 'package:learn_english_app/features/sentences/presentation/bloc/sentence_practice/sentence_practice_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSpeech extends Mock implements SpeechRecognitionService {}

void main() {
  late _MockSpeech mockSpeech;
  late StreamController<SpeechRecognitionUpdate> updateCtrl;

  setUp(() {
    mockSpeech = _MockSpeech();
    updateCtrl = StreamController<SpeechRecognitionUpdate>.broadcast();
    when(() => mockSpeech.updates).thenAnswer((_) => updateCtrl.stream);
    when(() => mockSpeech.start(continuous: any(named: 'continuous')))
        .thenAnswer((_) async => true);
    when(() => mockSpeech.stop()).thenAnswer((_) async {});
    when(() => mockSpeech.cancel()).thenAnswer((_) async {});
  });

  tearDown(() => updateCtrl.close());

  SentencePracticeBloc buildBloc() => SentencePracticeBloc(mockSpeech);

  // ── Start check ────────────────────────────────────────────────────────────

  blocTest<SentencePracticeBloc, SentencePracticeState>(
    'StartSentenceCheck sets activeSentenceId and starts speech',
    build: buildBloc,
    act: (bloc) => bloc.add(const StartSentenceCheck(
      sentenceId: 1,
      targetSentence: 'Hi there',
    )),
    expect: () => [
      isA<SentencePracticeState>()
          .having((s) => s.activeSentenceId, 'activeSentenceId', 1)
          .having((s) => s.armed, 'armed', false),
    ],
    verify: (_) => verify(
      () => mockSpeech.start(continuous: false),
    ).called(1),
  );

  // ── Continuous mode (conversation screens) ─────────────────────────────────

  blocTest<SentencePracticeBloc, SentencePracticeState>(
    'StartSentenceCheck(continuous: true) starts speech in continuous mode',
    build: buildBloc,
    act: (bloc) => bloc.add(const StartSentenceCheck(
      sentenceId: 1,
      targetSentence: 'Hello, how are you today',
      continuous: true,
    )),
    verify: (_) => verify(
      () => mockSpeech.start(continuous: true),
    ).called(1),
  );

  blocTest<SentencePracticeBloc, SentencePracticeState>(
    'continuous: restarting update with empty text keeps last partial',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const StartSentenceCheck(
        sentenceId: 2,
        targetSentence: 'Hello world',
        continuous: true,
      ));
      await Future.delayed(Duration.zero);
      bloc.add(SentenceSpeechUpdated(const SpeechRecognitionUpdate(
        text: 'hello',
        isFinalSegment: false,
        status: SpeechStatus.listening,
      )));
      await Future.delayed(Duration.zero);
      bloc.add(SentenceSpeechUpdated(const SpeechRecognitionUpdate(
        text: '',
        isFinalSegment: false,
        status: SpeechStatus.restarting,
      )));
    },
    expect: () => [
      isA<SentencePracticeState>().having((s) => s.activeSentenceId, 'id', 2),
      isA<SentencePracticeState>()
          .having((s) => s.partialText, 'partialText', 'hello'),
      isA<SentencePracticeState>()
          .having((s) => s.partialText, 'partialText (kept)', 'hello')
          .having((s) => s.armed, 'armed', true),
    ],
  );

  blocTest<SentencePracticeBloc, SentencePracticeState>(
    'continuous: auto-stops once transcript settles and covers the target',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const StartSentenceCheck(
        sentenceId: 3,
        targetSentence: 'Hello, how are you today?',
        continuous: true,
      ));
      await Future.delayed(Duration.zero);
      bloc.add(SentenceSpeechUpdated(const SpeechRecognitionUpdate(
        text: 'hello how are you',
        isFinalSegment: false,
        status: SpeechStatus.listening,
      )));
    },
    wait: const Duration(milliseconds: 2700),
    verify: (_) => verify(() => mockSpeech.stop()).called(1),
  );

  blocTest<SentencePracticeBloc, SentencePracticeState>(
    'continuous: does NOT auto-stop while coverage is low',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const StartSentenceCheck(
        sentenceId: 4,
        targetSentence: 'Hello, how are you today?',
        continuous: true,
      ));
      await Future.delayed(Duration.zero);
      bloc.add(SentenceSpeechUpdated(const SpeechRecognitionUpdate(
        text: 'hello',
        isFinalSegment: false,
        status: SpeechStatus.listening,
      )));
    },
    wait: const Duration(milliseconds: 2700),
    verify: (_) => verifyNever(() => mockSpeech.stop()),
  );

  blocTest<SentencePracticeBloc, SentencePracticeState>(
    'single-utterance mode never auto-stops',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const StartSentenceCheck(
        sentenceId: 5,
        targetSentence: 'Hello world',
      ));
      await Future.delayed(Duration.zero);
      bloc.add(SentenceSpeechUpdated(const SpeechRecognitionUpdate(
        text: 'hello world',
        isFinalSegment: false,
        status: SpeechStatus.listening,
      )));
    },
    wait: const Duration(milliseconds: 2700),
    verify: (_) => verifyNever(() => mockSpeech.stop()),
  );

  test('coverage ignores case and punctuation', () {
    expect(
      SentencePracticeBloc.coverage('hello how are you', 'Hello, how are you today?'),
      closeTo(0.8, 0.001),
    );
    expect(SentencePracticeBloc.coverage('', 'Hi'), 0);
    expect(SentencePracticeBloc.coverage('anything', ''), 1);
  });

  // ── Partial update (mid-speech) ────────────────────────────────────────────

  blocTest<SentencePracticeBloc, SentencePracticeState>(
    'partial SpeechUpdate shows partial text and arms',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const StartSentenceCheck(
        sentenceId: 2,
        targetSentence: 'Hello world',
      ));
      await Future.delayed(Duration.zero);
      bloc.add(SentenceSpeechUpdated(const SpeechRecognitionUpdate(
        text: 'hello',
        isFinalSegment: false,
        status: SpeechStatus.listening,
      )));
    },
    expect: () => [
      isA<SentencePracticeState>()
          .having((s) => s.activeSentenceId, 'id', 2),
      isA<SentencePracticeState>()
          .having((s) => s.partialText, 'partialText', 'hello')
          .having((s) => s.armed, 'armed', true),
    ],
  );

  // ── Successful assessment ──────────────────────────────────────────────────

  blocTest<SentencePracticeBloc, SentencePracticeState>(
    'final update with matching text → assessed with passed=true',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const StartSentenceCheck(
        sentenceId: 3,
        targetSentence: 'Hi there',
      ));
      await Future.delayed(Duration.zero);
      bloc.add(SentenceSpeechUpdated(const SpeechRecognitionUpdate(
        text: 'Hi there',
        isFinalSegment: true,
        status: SpeechStatus.stopped,
      )));
    },
    expect: () => [
      isA<SentencePracticeState>()
          .having((s) => s.activeSentenceId, 'id', 3),
      isA<SentencePracticeState>()
          .having((s) => s.activeSentenceId, 'id', null)
          .having(
              (s) => s.attempts[3]?.outcome,
              'outcome',
              SentencePracticeOutcome.assessed)
          .having(
              (s) => s.attempts[3]?.assessment?.passed,
              'passed',
              true),
    ],
  );

  // ── Permission denied ──────────────────────────────────────────────────────

  blocTest<SentencePracticeBloc, SentencePracticeState>(
    'permissionDenied failure → permissionDenied outcome',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const StartSentenceCheck(
        sentenceId: 4,
        targetSentence: 'Hi there',
      ));
      await Future.delayed(Duration.zero);
      bloc.add(SentenceSpeechUpdated(const SpeechRecognitionUpdate(
        text: '',
        isFinalSegment: true,
        status: SpeechStatus.failed,
        failure: SpeechFailure.permissionDenied,
      )));
    },
    expect: () => [
      isA<SentencePracticeState>()
          .having((s) => s.activeSentenceId, 'id', 4),
      isA<SentencePracticeState>()
          .having(
              (s) => s.attempts[4]?.outcome,
              'outcome',
              SentencePracticeOutcome.permissionDenied),
    ],
  );
}
