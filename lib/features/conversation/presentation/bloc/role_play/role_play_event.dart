import 'package:equatable/equatable.dart';

import '../../../../../core/speech/sentence_assessment.dart';

abstract class RolePlayEvent extends Equatable {
  const RolePlayEvent();
  @override
  List<Object?> get props => [];
}

/// Fetches the lesson's lines, pins the chosen character, and starts the
/// auto-play / wait-for-user sequence.
class LoadRolePlay extends RolePlayEvent {
  final int lessonId;
  final String character;
  const LoadRolePlay({required this.lessonId, required this.character});
  @override
  List<Object?> get props => [lessonId, character];
}

/// Internal — fires from the SoundPlayer completion stream so the bloc can
/// advance past a non-user line without needing a widget-level timer.
class RolePlayAudioCompleted extends RolePlayEvent {
  const RolePlayAudioCompleted();
}

/// User taps "Hear it first" on their turn — plays the current user line
/// without changing phase. If they tap again mid-playback, we stop.
class RolePlayPreviewUserLine extends RolePlayEvent {
  const RolePlayPreviewUserLine();
}

/// User tapped the mic to start speaking their current line.
class RolePlayStartUserMic extends RolePlayEvent {
  const RolePlayStartUserMic();
}

/// User tapped the mic again to cancel without a result.
class RolePlayStopUserMic extends RolePlayEvent {
  const RolePlayStopUserMic();
}

/// Fired by the player screen once a new assessed attempt lands in
/// [SentencePracticeState] for the current user line. The screen is the one
/// that watches the practice bloc; this bloc stays decoupled from it.
class RolePlayUserAttemptResult extends RolePlayEvent {
  final int lineId;
  final SentenceAssessment assessment;
  const RolePlayUserAttemptResult({
    required this.lineId,
    required this.assessment,
  });
  @override
  List<Object?> get props => [lineId, assessment.score, assessment.passed];
}

/// "Try again" on the result screen — reset results + rewind to line 0 with
/// the same character selection.
class RolePlayRestart extends RolePlayEvent {
  const RolePlayRestart();
}
