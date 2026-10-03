import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/speech/sentence_assessor.dart';
import '../../../../../core/speech/speech_models.dart';
import '../../../../../core/speech/speech_recognition_service.dart';
import '../../../../../core/utils/voice_preferences.dart';
import '../../../../../shared/enums/playback_speed.dart';
import 'sentence_practice_event.dart';
import 'sentence_practice_state.dart';

@injectable
class SentencePracticeBloc
    extends Bloc<SentencePracticeEvent, SentencePracticeState> {
  final SpeechRecognitionService _speech;

  StreamSubscription<SpeechRecognitionUpdate>? _sub;
  String _targetSentence = '';

  SentencePracticeBloc(this._speech)
      : super(SentencePracticeState(
          accent: AppVoicePreferences.instance.accent.value,
        )) {
    on<StartSentenceCheck>(_onStart);
    on<StopSentenceCheck>(_onStop);
    on<SentenceSpeechUpdated>(_onSpeechUpdated);
    on<ClearSentenceAttempt>(_onClearAttempt);
    on<_SetAccent>(_onSetAccent);
    on<_SetSpeed>(_onSetSpeed);
  }

  void _onClearAttempt(
    ClearSentenceAttempt event,
    Emitter<SentencePracticeState> emit,
  ) {
    if (!state.attempts.containsKey(event.sentenceId)) return;
    final next = Map<int, SentencePracticeAttempt>.from(state.attempts)
      ..remove(event.sentenceId);
    emit(state.copyWith(attempts: next));
  }

  void setAccent(VoiceAccent accent) => add(_SetAccent(accent));
  void setSpeed(PlaybackSpeed speed) => add(_SetSpeed(speed));

  Future<void> _onStart(
    StartSentenceCheck event,
    Emitter<SentencePracticeState> emit,
  ) async {
    await _sub?.cancel();
    _targetSentence = event.targetSentence;

    emit(state.copyWith(
      activeSentenceId: event.sentenceId,
      partialText: '',
      armed: false,
    ));

    _sub = _speech.updates.listen((u) => add(SentenceSpeechUpdated(u)));
    // Single-utterance capture — no continuous auto-restart needed for a
    // short sentence (that's for full-conversation features in Task 09).
    await _speech.start(continuous: false);
  }

  Future<void> _onStop(
    StopSentenceCheck event,
    Emitter<SentencePracticeState> emit,
  ) async {
    await _speech.stop();
  }

  void _onSpeechUpdated(
    SentenceSpeechUpdated event,
    Emitter<SentencePracticeState> emit,
  ) {
    final id = state.activeSentenceId;
    if (id == null) return;
    final update = event.update;

    if (!update.isFinalSegment) {
      emit(state.copyWith(partialText: update.text, armed: true));
      return;
    }

    final heard = update.text.trim();

    // Mirror PronunciationBloc's failure-case handling exactly.
    final attempt = switch (update.failure) {
      SpeechFailure.permissionDenied => SentencePracticeAttempt(
          outcome: SentencePracticeOutcome.permissionDenied,
          heard: heard,
        ),
      SpeechFailure.unavailable ||
      SpeechFailure.unrecoverable =>
        SentencePracticeAttempt(
          outcome: SentencePracticeOutcome.unavailable,
          heard: heard,
        ),
      null => heard.isEmpty
          ? SentencePracticeAttempt(
              outcome: SentencePracticeOutcome.noSpeech,
              heard: heard,
            )
          : SentencePracticeAttempt(
              outcome: SentencePracticeOutcome.assessed,
              heard: heard,
              assessment:
                  SentenceAssessor.assess(heard, _targetSentence),
            ),
    };

    final updated = Map<int, SentencePracticeAttempt>.from(state.attempts)
      ..[id] = attempt;

    emit(state.copyWith(clearActive: true, attempts: updated));
    unawaited(_sub?.cancel());
  }

  void _onSetAccent(
    _SetAccent event,
    Emitter<SentencePracticeState> emit,
  ) {
    if (state.accent == event.accent) return;
    AppVoicePreferences.instance.setAccent(event.accent);
    emit(state.copyWith(accent: event.accent));
  }

  void _onSetSpeed(
    _SetSpeed event,
    Emitter<SentencePracticeState> emit,
  ) {
    if (state.speed == event.speed) return;
    emit(state.copyWith(speed: event.speed));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _speech.cancel();
    return super.close();
  }
}

// Internal events for accent/speed — not exposed to widgets directly.
class _SetAccent extends SentencePracticeEvent {
  final VoiceAccent accent;
  const _SetAccent(this.accent);
}

class _SetSpeed extends SentencePracticeEvent {
  final PlaybackSpeed speed;
  const _SetSpeed(this.speed);
}
