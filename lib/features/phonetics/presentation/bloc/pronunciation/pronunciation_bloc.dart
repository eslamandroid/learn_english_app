import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/speech/speech_models.dart';
import '../../../../../core/speech/speech_recognition_service.dart';
import '../../../../../core/speech/speech_text_matcher.dart';
import '../../../domain/entities/pronunciation_outcome.dart';
import 'pronunciation_event.dart';
import 'pronunciation_state.dart';

@injectable
class PronunciationBloc extends Bloc<PronunciationEvent, PronunciationState> {
  final SpeechRecognitionService _speech;

  StreamSubscription<SpeechRecognitionUpdate>? _sub;
  String _targetWord = '';

  PronunciationBloc(this._speech) : super(const PronunciationState()) {
    on<StartPronunciationCheck>(_onStart);
    on<StopPronunciationCheck>(_onStop);
    on<PronunciationSpeechUpdated>(_onSpeechUpdated);
  }

  Future<void> _onStart(
    StartPronunciationCheck event,
    Emitter<PronunciationState> emit,
  ) async {
    await _sub?.cancel();
    _targetWord = event.targetWord;

    emit(state.copyWith(
      activeExampleId: event.exampleId,
      partialText: '',
      armed: false,
    ));

    _sub = _speech.updates.listen((u) => add(PronunciationSpeechUpdated(u)));

    // Single-utterance capture — one word/short phrase, so no continuous
    // auto-restart is needed here (that's for full-sentence features).
    await _speech.start(continuous: false);
  }

  Future<void> _onStop(
    StopPronunciationCheck event,
    Emitter<PronunciationState> emit,
  ) async {
    await _speech.stop();
  }

  void _onSpeechUpdated(
    PronunciationSpeechUpdated event,
    Emitter<PronunciationState> emit,
  ) {
    final id = state.activeExampleId;
    if (id == null) return;
    final update = event.update;

    if (!update.isFinalSegment) {
      emit(state.copyWith(partialText: update.text, armed: true));
      return;
    }

    final heard = update.text.trim();
    final outcome = switch (update.failure) {
      SpeechFailure.permissionDenied => PronunciationOutcome.denied,
      SpeechFailure.unavailable ||
      SpeechFailure.unrecoverable =>
        PronunciationOutcome.unavailable,
      null => heard.isEmpty
          ? PronunciationOutcome.noSpeech
          : (SpeechTextMatcher.matches(heard, _targetWord)
              ? PronunciationOutcome.correct
              : PronunciationOutcome.incorrect),
    };

    final attempts = Map<int, PronunciationAttempt>.from(state.attempts)
      ..[id] = PronunciationAttempt(outcome: outcome, heard: heard);

    emit(state.copyWith(clearActiveExample: true, attempts: attempts));
    unawaited(_sub?.cancel());
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _speech.cancel();
    return super.close();
  }
}
