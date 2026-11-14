import 'package:equatable/equatable.dart';

import '../../../../../shared/enums/playback_speed.dart';

abstract class ConversationPlayerEvent extends Equatable {
  const ConversationPlayerEvent();
  @override
  List<Object?> get props => [];
}

class LoadConversationLines extends ConversationPlayerEvent {
  final int lessonId;
  const LoadConversationLines({required this.lessonId});
  @override
  List<Object?> get props => [lessonId];
}

/// Start / resume the auto-play sequence from `currentIndex` (or 0).
class PlayConversationSequence extends ConversationPlayerEvent {
  const PlayConversationSequence();
}

/// Pause the auto-play sequence (keeps `currentIndex` so a later Play resumes).
class PauseConversationSequence extends ConversationPlayerEvent {
  const PauseConversationSequence();
}

/// Jump to and play the given index.
class JumpToConversationLine extends ConversationPlayerEvent {
  final int index;
  const JumpToConversationLine(this.index);
  @override
  List<Object?> get props => [index];
}

class NextConversationLine extends ConversationPlayerEvent {
  const NextConversationLine();
}

class PreviousConversationLine extends ConversationPlayerEvent {
  const PreviousConversationLine();
}

/// Play only [lineId] — does NOT change the sequence pointer or resume
/// auto-play after the clip ends. Used by the per-bubble 🔊 button.
class PlayConversationSingle extends ConversationPlayerEvent {
  final int lineId;
  const PlayConversationSingle(this.lineId);
  @override
  List<Object?> get props => [lineId];
}

class SetConversationSpeed extends ConversationPlayerEvent {
  final PlaybackSpeed speed;
  const SetConversationSpeed(this.speed);
  @override
  List<Object?> get props => [speed];
}

class MarkConversationComplete extends ConversationPlayerEvent {
  final int lessonId;
  const MarkConversationComplete({required this.lessonId});
  @override
  List<Object?> get props => [lessonId];
}

/// Internal — fires on every SoundPlayer completion so the bloc can advance
/// the sequence or clear the single-play flag.
class ConversationAudioCompleted extends ConversationPlayerEvent {
  const ConversationAudioCompleted();
}
