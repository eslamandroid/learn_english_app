import 'package:equatable/equatable.dart';

import '../../../domain/entities/pronunciation_outcome.dart';

class PronunciationState extends Equatable {
  /// The example currently being listened to, or null when idle.
  final int? activeExampleId;

  /// Live partial transcript for [activeExampleId] while listening.
  final String partialText;

  /// True once the engine has confirmed the mic is actually armed and
  /// capturing (not just "the user tapped mic"). Anything said before this
  /// flips true can be lost to mic/audio-focus startup latency — the UI
  /// should tell the user to wait for this, not just show a mic icon the
  /// instant they tap it.
  final bool armed;

  /// Graded result of the last attempt per example id.
  final Map<int, PronunciationAttempt> attempts;

  const PronunciationState({
    this.activeExampleId,
    this.partialText = '',
    this.armed = false,
    this.attempts = const {},
  });

  PronunciationState copyWith({
    int? activeExampleId,
    bool clearActiveExample = false,
    String? partialText,
    bool? armed,
    Map<int, PronunciationAttempt>? attempts,
  }) {
    return PronunciationState(
      activeExampleId:
          clearActiveExample ? null : (activeExampleId ?? this.activeExampleId),
      partialText: partialText ?? this.partialText,
      armed: armed ?? this.armed,
      attempts: attempts ?? this.attempts,
    );
  }

  @override
  List<Object?> get props => [activeExampleId, partialText, armed, attempts];
}
