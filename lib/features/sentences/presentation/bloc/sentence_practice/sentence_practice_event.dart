import 'package:equatable/equatable.dart';

import '../../../../../core/speech/speech_models.dart';

abstract class SentencePracticeEvent extends Equatable {
  const SentencePracticeEvent();
  @override
  List<Object?> get props => [];
}

/// User tapped the mic for [sentenceId] to practise saying [targetSentence].
class StartSentenceCheck extends SentencePracticeEvent {
  final int sentenceId;
  final String targetSentence;

  /// `false` (default) = single-utterance capture: the engine's first final
  /// result ends the session. Right for one short sentence on the Sentences
  /// screen.
  ///
  /// `true` = dictation mode with auto-restart across pauses and the
  /// engine's own segment limits. Required for conversation lines, which
  /// are longer and contain natural pauses — in single-utterance mode the
  /// recognizer cut them off mid-sentence. When `true` the bloc also stops
  /// the session on its own once the transcript has settled and covers the
  /// target (see [SentencePracticeBloc]), so the user doesn't have to tap
  /// the mic again.
  final bool continuous;

  const StartSentenceCheck({
    required this.sentenceId,
    required this.targetSentence,
    this.continuous = false,
  });

  @override
  List<Object?> get props => [sentenceId, targetSentence, continuous];
}

/// User tapped mic again to stop early.
class StopSentenceCheck extends SentencePracticeEvent {
  const StopSentenceCheck();
}

/// Internal — fired by the bloc's STT subscription.
class SentenceSpeechUpdated extends SentencePracticeEvent {
  final SpeechRecognitionUpdate update;
  const SentenceSpeechUpdated(this.update);
}

/// User tapped "Try again" inside the YOU SAID / GREAT result box — drop
/// the recorded attempt so the box disappears and the mic goes back to idle.
class ClearSentenceAttempt extends SentencePracticeEvent {
  final int sentenceId;
  const ClearSentenceAttempt({required this.sentenceId});
  @override
  List<Object?> get props => [sentenceId];
}
