import 'package:equatable/equatable.dart';

import '../../../domain/entities/conversation_line.dart';

enum RolePlayPhase {
  /// Lines not yet fetched.
  loading,

  /// Currently playing a line belonging to a character other than the user.
  autoPlaying,

  /// Reached a user line; audio stopped; mic armed and waiting for a tap.
  waitingForUser,

  /// User tapped the mic — speech recognition in flight.
  checking,

  /// User's last attempt passed; brief pause before auto-advance.
  passed,

  /// Reached the end of lines.
  finished,

  error,
}

/// One user line's running summary (ephemeral — never written to any DB).
class RoleLineResult extends Equatable {
  /// Highest `assessment.score` among the attempts for this line, in 0..1.
  final double bestScore;

  /// How many attempts the user made before passing (counts the passing one).
  final int attempts;

  /// True iff the user passed this line on their first attempt (`attempts == 1`).
  final bool passedFirstTry;

  const RoleLineResult({
    required this.bestScore,
    required this.attempts,
    required this.passedFirstTry,
  });

  RoleLineResult copyWith({
    double? bestScore,
    int? attempts,
    bool? passedFirstTry,
  }) {
    return RoleLineResult(
      bestScore: bestScore ?? this.bestScore,
      attempts: attempts ?? this.attempts,
      passedFirstTry: passedFirstTry ?? this.passedFirstTry,
    );
  }

  @override
  List<Object?> get props => [bestScore, attempts, passedFirstTry];
}

class RolePlayState extends Equatable {
  final RolePlayPhase phase;
  final List<ConversationLine> lines;
  final String selectedCharacter;

  /// Index into [lines]. When [phase] == finished, this equals `lines.length`.
  final int currentIndex;

  /// Per-user-line summary, keyed by [ConversationLine.id].
  final Map<int, RoleLineResult> results;

  /// Non-null while the bloc is actively playing audio (either a non-user
  /// line auto-play or a user line preview).
  final int? playingLineId;

  final String? errorMessage;

  const RolePlayState({
    this.phase = RolePlayPhase.loading,
    this.lines = const [],
    this.selectedCharacter = '',
    this.currentIndex = 0,
    this.results = const {},
    this.playingLineId,
    this.errorMessage,
  });

  ConversationLine? get currentLine =>
      currentIndex >= 0 && currentIndex < lines.length
          ? lines[currentIndex]
          : null;

  /// True if the current line belongs to the user's selected character.
  bool get isUserTurn => currentLine?.character == selectedCharacter;

  /// Count of lines in the whole lesson that are the user's.
  int get totalUserLines =>
      lines.where((l) => l.character == selectedCharacter).length;

  /// Count of user lines resolved so far (via [results]).
  int get passedUserLines => results.length;

  /// 0..1 progress through the lesson, counted in raw line position (so the
  /// progress bar matches the visible scroll position in the player).
  double get progress {
    if (lines.isEmpty) return 0;
    return (currentIndex.clamp(0, lines.length)) / lines.length;
  }

  RolePlayState copyWith({
    RolePlayPhase? phase,
    List<ConversationLine>? lines,
    String? selectedCharacter,
    int? currentIndex,
    Map<int, RoleLineResult>? results,
    int? playingLineId,
    bool clearPlaying = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RolePlayState(
      phase: phase ?? this.phase,
      lines: lines ?? this.lines,
      selectedCharacter: selectedCharacter ?? this.selectedCharacter,
      currentIndex: currentIndex ?? this.currentIndex,
      results: results ?? this.results,
      playingLineId:
          clearPlaying ? null : (playingLineId ?? this.playingLineId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        phase,
        lines,
        selectedCharacter,
        currentIndex,
        results,
        playingLineId,
        errorMessage,
      ];
}
