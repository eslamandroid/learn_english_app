import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/audio/sound_player.dart';
import '../../../../../core/network/cdn_config.dart';
import '../../../../../features/progress/domain/usecases/mark_conversation_lesson_completed.dart';
import '../../../../../features/progress/domain/usecases/mark_conversation_lesson_started.dart';
import '../../../domain/entities/conversation_line.dart';
import '../../../domain/usecases/get_conversation_lines.dart';
import 'conversation_player_event.dart';
import 'conversation_player_state.dart';

/// Chat auto-play + per-line one-off playback + current-line tracking.
///
/// Design decisions worth calling out:
///   • Auto-play advances via [SoundPlayer.completionStream], not timers —
///     so slow mode / network latency / cache cold starts don't desync the
///     "now playing" bubble.
///   • Single-line play ([PlayConversationSingle]) sets `isSinglePlay`;
///     completion clears the playingLineId but does NOT advance the pointer.
///     User must tap play again to resume the sequence (TASK 10 §6).
///   • No UK/US here — accent comes from `AppVoicePreferences` (global
///     settings only, TASK 10 §6 / §13).
@injectable
class ConversationPlayerBloc
    extends Bloc<ConversationPlayerEvent, ConversationPlayerState> {
  final GetConversationLines _getLines;
  final SoundPlayer _soundPlayer;
  final MarkConversationLessonStarted _markStarted;
  final MarkConversationLessonCompleted _markCompleted;

  StreamSubscription<SoundSource>? _completionSub;

  ConversationPlayerBloc(
    this._getLines,
    this._soundPlayer,
    this._markStarted,
    this._markCompleted,
  ) : super(const ConversationPlayerState()) {
    on<LoadConversationLines>(_onLoad);
    on<PlayConversationSequence>(_onPlaySequence);
    on<PauseConversationSequence>(_onPause);
    on<JumpToConversationLine>(_onJump);
    on<NextConversationLine>(_onNext);
    on<PreviousConversationLine>(_onPrevious);
    on<PlayConversationSingle>(_onPlaySingle);
    on<SetConversationSpeed>(_onSetSpeed);
    on<MarkConversationComplete>(_onMarkComplete);
    on<ConversationAudioCompleted>(_onAudioCompleted);

    _completionSub = _soundPlayer.completionStream.listen((_) {
      if (state.playingLineId != null) {
        add(const ConversationAudioCompleted());
      }
    });
  }

  Future<void> _onLoad(
    LoadConversationLines event,
    Emitter<ConversationPlayerState> emit,
  ) async {
    emit(state.copyWith(
      status: ConversationPlayerStatus.loading,
      clearError: true,
    ));
    await _markStarted.execute(lessonId: event.lessonId);
    final result = await _getLines.execute(lessonId: event.lessonId);
    result.fold(
      (err) => emit(state.copyWith(
        status: ConversationPlayerStatus.error,
        errorMessage: err.toString(),
      )),
      (lines) => emit(state.copyWith(
        status: ConversationPlayerStatus.loaded,
        lines: lines,
        currentIndex: 0,
      )),
    );
  }

  Future<void> _onPlaySequence(
    PlayConversationSequence event,
    Emitter<ConversationPlayerState> emit,
  ) async {
    if (state.lines.isEmpty) return;
    emit(state.copyWith(isAutoPlaying: true));
    await _playLineAt(state.currentIndex, isSingle: false, emit: emit);
  }

  Future<void> _onPause(
    PauseConversationSequence event,
    Emitter<ConversationPlayerState> emit,
  ) async {
    await _soundPlayer.stop();
    emit(state.copyWith(
      isAutoPlaying: false,
      clearPlaying: true,
      isSinglePlay: false,
    ));
  }

  Future<void> _onJump(
    JumpToConversationLine event,
    Emitter<ConversationPlayerState> emit,
  ) async {
    if (state.lines.isEmpty) return;
    final idx = event.index.clamp(0, state.lines.length - 1);
    emit(state.copyWith(currentIndex: idx));
    if (state.isAutoPlaying) {
      await _playLineAt(idx, isSingle: false, emit: emit);
    }
  }

  Future<void> _onNext(
    NextConversationLine event,
    Emitter<ConversationPlayerState> emit,
  ) async {
    if (!state.hasNext) return;
    add(JumpToConversationLine(state.currentIndex + 1));
  }

  Future<void> _onPrevious(
    PreviousConversationLine event,
    Emitter<ConversationPlayerState> emit,
  ) async {
    if (!state.hasPrevious) return;
    add(JumpToConversationLine(state.currentIndex - 1));
  }

  Future<void> _onPlaySingle(
    PlayConversationSingle event,
    Emitter<ConversationPlayerState> emit,
  ) async {
    debugPrint(
      '🗣️ ConversationPlayerBloc._onPlaySingle lineId=${event.lineId} '
      'playingLineId=${state.playingLineId} isSinglePlay=${state.isSinglePlay} '
      'lines=${state.lines.length}',
    );
    // Guard: if the lesson's lines haven't finished loading we have nothing
    // to play. Previously this fell through to firstWhere().orElse → first,
    // which silently played the wrong clip (or exploded on empty list,
    // depending on timing). Surface it instead.
    if (state.lines.isEmpty) {
      debugPrint('🗣️ _onPlaySingle: state.lines is empty — ignoring.');
      emit(state.copyWith(errorMessage: 'Lines are still loading.'));
      return;
    }
    // Stop-toggle: tapping the already-playing single-play line stops it.
    if (state.playingLineId == event.lineId && state.isSinglePlay) {
      await _soundPlayer.stop();
      emit(state.copyWith(clearPlaying: true, isSinglePlay: false));
      return;
    }
    // Single play interrupts auto-play; the sequence pointer is preserved so
    // the user can resume with the play button afterward.
    emit(state.copyWith(
      isAutoPlaying: false,
      isSinglePlay: true,
      playingLineId: event.lineId,
      clearError: true,
    ));
    await _playLineById(event.lineId, isSingle: true, emit: emit);
  }

  void _onSetSpeed(
    SetConversationSpeed event,
    Emitter<ConversationPlayerState> emit,
  ) {
    if (state.speed == event.speed) return;
    emit(state.copyWith(speed: event.speed));
  }

  Future<void> _onMarkComplete(
    MarkConversationComplete event,
    Emitter<ConversationPlayerState> emit,
  ) async {
    await _markCompleted.execute(lessonId: event.lessonId);
    emit(state.copyWith(isCompleted: true));
  }

  Future<void> _onAudioCompleted(
    ConversationAudioCompleted event,
    Emitter<ConversationPlayerState> emit,
  ) async {
    // One-off single play finished — just clear the playing flag.
    if (state.isSinglePlay) {
      emit(state.copyWith(clearPlaying: true, isSinglePlay: false));
      return;
    }
    // Auto-play finished — advance, or stop if at the last line (TASK 10 §6
    // "no auto-play between lessons").
    if (!state.isAutoPlaying) return;
    if (state.hasNext) {
      final nextIdx = state.currentIndex + 1;
      emit(state.copyWith(currentIndex: nextIdx));
      await _playLineAt(nextIdx, isSingle: false, emit: emit);
    } else {
      emit(state.copyWith(
        isAutoPlaying: false,
        clearPlaying: true,
      ));
    }
  }

  Future<void> _playLineAt(
    int index, {
    required bool isSingle,
    required Emitter<ConversationPlayerState> emit,
  }) async {
    if (index < 0 || index >= state.lines.length) return;
    final line = state.lines[index];
    emit(state.copyWith(
      playingLineId: line.id,
      isSinglePlay: isSingle,
    ));
    await _playAudio(line, emit: emit);
  }

  /// Same as [_playLineAt] but keyed by line id (used by single-play, which
  /// doesn't advance the sequence pointer so we don't need the index).
  Future<void> _playLineById(
    int lineId, {
    required bool isSingle,
    required Emitter<ConversationPlayerState> emit,
  }) async {
    // Previously this used firstWhere with orElse → first, which silently
    // played the wrong clip when the id wasn't in state.lines. Prefer a
    // nullable lookup + an explicit error state so the UI can surface it.
    final line = _lineById(lineId);
    if (line == null) {
      debugPrint('🗣️ _playLineById: no line with id=$lineId in state.lines');
      emit(state.copyWith(
        clearPlaying: true,
        isSinglePlay: false,
        errorMessage: "Couldn't find that line.",
      ));
      return;
    }
    await _playAudio(line, emit: emit);
  }

  ConversationLine? _lineById(int id) {
    for (final l in state.lines) {
      if (l.id == id) return l;
    }
    return null;
  }

  Future<void> _playAudio(
    ConversationLine line, {
    required Emitter<ConversationPlayerState> emit,
  }) async {
    final url = CdnConfig.conversationAudio(line.id, CdnConfig.currentVoice);
    debugPrint('🗣️ playing line ${line.id} url=$url rate=${state.speed.rate}');
    try {
      final src = await _soundPlayer.play(
        cdnUrl: url,
        fallbackText: line.english,
        rate: state.speed.rate,
      );
      debugPrint('🗣️ _soundPlayer.play returned source=$src for line ${line.id}');
    } catch (e, st) {
      // The 4-tier chain in SoundPlayer already handles the usual failures
      // (cache miss → CDN → device TTS → Google TTS). Anything that still
      // throws is unexpected (I/O crash, codec error, etc.) — surface it to
      // the user instead of leaving the "playing" state stuck on the icon.
      debugPrint('🗣️ _soundPlayer.play threw for line ${line.id}: $e\n$st');
      emit(state.copyWith(
        clearPlaying: true,
        isSinglePlay: false,
        errorMessage: 'Playback failed — tap again to retry.',
      ));
    }
  }

  @override
  Future<void> close() async {
    await _completionSub?.cancel();
    await _soundPlayer.stop();
    return super.close();
  }

  /// Exposed for tests to force a synthetic completion event without running
  /// a real audio player — the production listener keyed off completionStream
  /// is the only live wiring.
  void debugCompleteOne() => add(const ConversationAudioCompleted());
}

/// Convenience helpers reused by tests + widgets that only need the list of
/// unique characters in appearance order.
extension ConversationLinesExtras on List<ConversationLine> {
  /// Characters in the order of first appearance — drives the chat bubble
  /// alignment and avatar color assignment (TASK 10 §6).
  List<String> uniqueCharactersInOrder() {
    final seen = <String>{};
    final out = <String>[];
    for (final l in this) {
      if (seen.add(l.character)) out.add(l.character);
    }
    return out;
  }
}
