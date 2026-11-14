import 'package:equatable/equatable.dart';

import '../../../../../core/speech/speech_models.dart';

abstract class PronunciationEvent extends Equatable {
  const PronunciationEvent();

  @override
  List<Object?> get props => [];
}

/// User tapped the mic on [exampleId] to try saying [targetWord].
class StartPronunciationCheck extends PronunciationEvent {
  final int exampleId;
  final String targetWord;

  const StartPronunciationCheck({
    required this.exampleId,
    required this.targetWord,
  });

  @override
  List<Object?> get props => [exampleId, targetWord];
}

/// User tapped the mic again mid-listen to finish early.
class StopPronunciationCheck extends PronunciationEvent {
  const StopPronunciationCheck();
}

/// Internal event — fired by the bloc's subscription to
/// [SpeechRecognitionService.updates].
class PronunciationSpeechUpdated extends PronunciationEvent {
  final SpeechRecognitionUpdate update;

  const PronunciationSpeechUpdated(this.update);
}
