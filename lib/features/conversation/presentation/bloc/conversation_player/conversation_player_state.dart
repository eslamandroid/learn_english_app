import 'package:equatable/equatable.dart';

import '../../../../../shared/enums/playback_speed.dart';
import '../../../domain/entities/conversation_line.dart';

enum ConversationPlayerStatus { initial, loading, loaded, error }

/// Player state. One source of truth for both Chat and Pager views.
class ConversationPlayerState extends Equatable {
  final ConversationPlayerStatus status;
  final List<ConversationLine> lines;

  /// Index of the "current" line in the auto-play sequence. When
  /// [isAutoPlaying] is true, this is the line being played; when paused,
  /// it's the one that will play next.
  final int currentIndex;

  /// True while the auto-play sequence is advancing through lines on
  /// completion. Independent of a one-off single-line play.
  final bool isAutoPlaying;

  /// Id of the line whose audio is actively playing right now — null when
  /// nothing is playing. Could be the auto-play's current line OR a single-
  /// line one-off; the UI uses this for the 🔊 button's stop-toggle state.
  final int? playingLineId;

  /// True iff the current playback is a one-off (user tapped a bubble's
  /// 🔊 button). On completion the sequence will NOT auto-advance.
  final bool isSinglePlay;

  final PlaybackSpeed speed;
  final bool isCompleted;
  final String? errorMessage;

  const ConversationPlayerState({
    this.status = ConversationPlayerStatus.initial,
    this.lines = const [],
    this.currentIndex = 0,
    this.isAutoPlaying = false,
    this.playingLineId,
    this.isSinglePlay = false,
    this.speed = PlaybackSpeed.normal,
    this.isCompleted = false,
    this.errorMessage,
  });

  ConversationLine? get currentLine =>
      lines.isEmpty ? null : lines[currentIndex.clamp(0, lines.length - 1)];

  bool get hasNext => currentIndex < lines.length - 1;
  bool get hasPrevious => currentIndex > 0;

  ConversationPlayerState copyWith({
    ConversationPlayerStatus? status,
    List<ConversationLine>? lines,
    int? currentIndex,
    bool? isAutoPlaying,
    int? playingLineId,
    bool clearPlaying = false,
    bool? isSinglePlay,
    PlaybackSpeed? speed,
    bool? isCompleted,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ConversationPlayerState(
      status: status ?? this.status,
      lines: lines ?? this.lines,
      currentIndex: currentIndex ?? this.currentIndex,
      isAutoPlaying: isAutoPlaying ?? this.isAutoPlaying,
      playingLineId:
          clearPlaying ? null : (playingLineId ?? this.playingLineId),
      isSinglePlay: isSinglePlay ?? this.isSinglePlay,
      speed: speed ?? this.speed,
      isCompleted: isCompleted ?? this.isCompleted,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        lines,
        currentIndex,
        isAutoPlaying,
        playingLineId,
        isSinglePlay,
        speed,
        isCompleted,
        errorMessage,
      ];
}
