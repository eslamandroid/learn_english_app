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

  const StartSentenceCheck({
    required this.sentenceId,
    required this.targetSentence,
  });

  @override
  List<Object?> get props => [sentenceId, targetSentence];
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
