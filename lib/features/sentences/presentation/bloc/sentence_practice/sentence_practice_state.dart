import 'package:equatable/equatable.dart';

import '../../../../../core/speech/sentence_assessment.dart';
import '../../../../../core/utils/voice_preferences.dart';
import '../../../../../shared/enums/playback_speed.dart';

/// Outcome bucket for the final result of one sentence check attempt.
enum SentencePracticeOutcome {
  /// Assessment completed — see [SentencePracticeAttempt.assessment].
  assessed,
  noSpeech,
  permissionDenied,
  unavailable,
}

class SentencePracticeAttempt {
  final SentencePracticeOutcome outcome;

  /// Non-null when [outcome] == [SentencePracticeOutcome.assessed].
  final SentenceAssessment? assessment;
  final String heard;

  /// Absolute path to the user's recorded take for this attempt, if the
  /// parallel recorder in [SpeechRecognitionService] produced one. Null
  /// when the recorder couldn't start — see TASK 12 §3.
  final String? recordingPath;

  const SentencePracticeAttempt({
    required this.outcome,
    required this.heard,
    this.assessment,
    this.recordingPath,
  });
}

class SentencePracticeState extends Equatable {
  /// The sentence currently being listened to, or null when idle.
  final int? activeSentenceId;

  /// Live partial transcript while listening.
  final String partialText;

  /// True once the mic is armed and capturing.
  final bool armed;

  /// Per-sentence assessment keyed by sentence id.
  final Map<int, SentencePracticeAttempt> attempts;

  /// Current accent selection (persists across cards within the screen).
  final VoiceAccent accent;

  /// Current playback speed.
  final PlaybackSpeed speed;

  const SentencePracticeState({
    this.activeSentenceId,
    this.partialText = '',
    this.armed = false,
    this.attempts = const {},
    this.accent = VoiceAccent.us,
    this.speed = PlaybackSpeed.normal,
  });

  bool get isListening => activeSentenceId != null;

  SentencePracticeState copyWith({
    int? activeSentenceId,
    bool clearActive = false,
    String? partialText,
    bool? armed,
    Map<int, SentencePracticeAttempt>? attempts,
    VoiceAccent? accent,
    PlaybackSpeed? speed,
  }) {
    return SentencePracticeState(
      activeSentenceId: clearActive
          ? null
          : (activeSentenceId ?? this.activeSentenceId),
      partialText: partialText ?? this.partialText,
      armed: armed ?? this.armed,
      attempts: attempts ?? this.attempts,
      accent: accent ?? this.accent,
      speed: speed ?? this.speed,
    );
  }

  @override
  List<Object?> get props => [
        activeSentenceId,
        partialText,
        armed,
        attempts,
        accent,
        speed,
      ];
}
