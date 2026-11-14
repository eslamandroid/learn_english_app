import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/speech/speech_models.dart';
import 'package:learn_english_app/core/speech/speech_recognition_service.dart';
import 'package:learn_english_app/features/phonetics/domain/entities/pronunciation_outcome.dart';
import 'package:learn_english_app/features/phonetics/presentation/bloc/pronunciation/pronunciation_bloc.dart';
import 'package:learn_english_app/features/phonetics/presentation/bloc/pronunciation/pronunciation_event.dart';
import 'package:learn_english_app/features/phonetics/presentation/bloc/pronunciation/pronunciation_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSpeech extends Mock implements SpeechRecognitionService {}

/// TASK 12.1 §C — the audit insists that *every* non-permission outcome
/// surfaces a replay button. For `noSpeech` that only works if the bloc
/// actually builds a PronunciationAttempt with the update's `recordingPath`
/// attached (and doesn't bail out to a null attempt on empty transcript).
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

  PronunciationBloc buildBloc() => PronunciationBloc(mockSpeech);

  blocTest<PronunciationBloc, PronunciationState>(
    'final empty transcript → noSpeech attempt that still carries '
    'recordingPath (so the user can replay what the mic actually captured)',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const StartPronunciationCheck(
        exampleId: 42,
        targetWord: 'hello',
      ));
      await Future.delayed(Duration.zero);
      bloc.add(const PronunciationSpeechUpdated(SpeechRecognitionUpdate(
        text: '',
        isFinalSegment: true,
        status: SpeechStatus.stopped,
        recordingPath: '/tmp/practice_takes/take_42.m4a',
      )));
    },
    skip: 1, // skip the StartPronunciationCheck state
    expect: () => [
      isA<PronunciationState>()
          .having((s) => s.activeExampleId, 'activeExampleId', isNull)
          .having(
            (s) => s.attempts[42]?.outcome,
            'outcome',
            PronunciationOutcome.noSpeech,
          )
          .having(
            (s) => s.attempts[42]?.recordingPath,
            'recordingPath',
            '/tmp/practice_takes/take_42.m4a',
          ),
    ],
  );

  blocTest<PronunciationBloc, PronunciationState>(
    'permissionDenied failure → denied outcome with NO recording path '
    '(recorder never started, so the replay button must collapse)',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const StartPronunciationCheck(
        exampleId: 7,
        targetWord: 'cat',
      ));
      await Future.delayed(Duration.zero);
      bloc.add(const PronunciationSpeechUpdated(SpeechRecognitionUpdate(
        text: '',
        isFinalSegment: true,
        status: SpeechStatus.failed,
        failure: SpeechFailure.permissionDenied,
      )));
    },
    skip: 1,
    expect: () => [
      isA<PronunciationState>()
          .having(
            (s) => s.attempts[7]?.outcome,
            'outcome',
            PronunciationOutcome.denied,
          )
          .having(
            (s) => s.attempts[7]?.recordingPath,
            'recordingPath',
            isNull,
          ),
    ],
  );
}
