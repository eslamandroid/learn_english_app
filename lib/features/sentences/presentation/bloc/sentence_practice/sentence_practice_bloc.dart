import 'dart:async';

import 'package:flutter/foundation.dart';
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
  bool _continuous = false;

  /// Auto-stop for continuous sessions. The service's own `pauseFor` is
  /// deliberately long (it exists to NOT cut the user off), so without this
  /// a learner who finished the line would sit through pauseFor + grace
  /// before seeing a result. Instead: once the rolling transcript has not
  /// changed for [_settleDelay] AND it already covers [_coverageToStop] of
  /// the target's words, we stop the session ourselves. If the user is
  /// still talking the transcript keeps changing and the timer keeps being
  /// pushed back, so this never cuts a sentence short.
  Timer? _settleTimer;
  static const _settleDelay = Duration(milliseconds: 2500);
  static const _coverageToStop = 0.7;

  /// Word-coverage of [target] by [heard]: fraction of distinct target
  /// words that appear in the transcript (case/punctuation-insensitive).
  @visibleForTesting
  static double coverage(String heard, String target) {
    final targetWords = _words(target).toSet();
    if (targetWords.isEmpty) return 1;
    final heardWords = _words(heard).toSet();
    final hit = targetWords.where(heardWords.contains).length;
    return hit / targetWords.length;
  }

  static Iterable<String> _words(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9'\s]"), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty);

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
    _settleTimer?.cancel();
    _targetSentence = event.targetSentence;
    _continuous = event.continuous;

    emit(state.copyWith(
      activeSentenceId: event.sentenceId,
      partialText: '',
      armed: false,
    ));

    _sub = _speech.updates.listen((u) => add(SentenceSpeechUpdated(u)));
    // Sentences screen: single-utterance capture. Conversation screens pass
    // continuous=true so long lines with natural pauses aren't cut off by
    // the engine's own segment limits (see StartSentenceCheck.continuous).
    await _speech.start(continuous: event.continuous);
  }

  Future<void> _onStop(
    StopSentenceCheck event,
    Emitter<SentencePracticeState> emit,
  ) async {
    _settleTimer?.cancel();
    await _speech.stop();
  }

  void _armSettleTimer(String partial) {
    _settleTimer?.cancel();
    if (!_continuous) return;
    if (coverage(partial, _targetSentence) < _coverageToStop) return;
    _settleTimer = Timer(_settleDelay, () {
      if (isClosed || state.activeSentenceId == null) return;
      add(const StopSentenceCheck());
    });
  }

  void _onSpeechUpdated(
    SentenceSpeechUpdated event,
    Emitter<SentencePracticeState> emit,
  ) {
    final id = state.activeSentenceId;
    if (id == null) return;
    final update = event.update;

    if (!update.isFinalSegment) {
      // During an auto-restart the service emits with only the committed
      // text (the in-flight partial of the segment that just ended is
      // gone). Keep showing what the user last saw instead of flashing an
      // emptier transcript, so the strip never reads as "stopped".
      final isRestart = update.status == SpeechStatus.restarting;
      final partial =
          isRestart && update.text.trim().length < state.partialText.length
              ? state.partialText
              : update.text;
      if (partial != state.partialText) _armSettleTimer(partial);
      emit(state.copyWith(partialText: partial, armed: true));
      return;
    }

    _settleTimer?.cancel();
    final heard = update.text.trim();

    // Mirror PronunciationBloc's failure-case handling exactly. The parallel
    // recording path (if any) rides on every outcome — even noSpeech /
    // denied, since the user might still want to hear what their mic picked
    // up before giving up.
    final recordingPath = update.recordingPath;
    final attempt = switch (update.failure) {
      SpeechFailure.permissionDenied => SentencePracticeAttempt(
          outcome: SentencePracticeOutcome.permissionDenied,
          heard: heard,
          recordingPath: recordingPath,
        ),
      SpeechFailure.unavailable ||
      SpeechFailure.unrecoverable =>
        SentencePracticeAttempt(
          outcome: SentencePracticeOutcome.unavailable,
          heard: heard,
          recordingPath: recordingPath,
        ),
      null => heard.isEmpty
          ? SentencePracticeAttempt(
              outcome: SentencePracticeOutcome.noSpeech,
              heard: heard,
              recordingPath: recordingPath,
            )
          : SentencePracticeAttempt(
              outcome: SentencePracticeOutcome.assessed,
              heard: heard,
              recordingPath: recordingPath,
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
    _settleTimer?.cancel();
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
