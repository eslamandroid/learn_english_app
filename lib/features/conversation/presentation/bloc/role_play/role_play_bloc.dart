import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/audio/sound_player.dart';
import '../../../../../core/network/cdn_config.dart';
import '../../../domain/entities/conversation_line.dart';
import '../../../domain/usecases/get_conversation_lines.dart';
import 'role_play_event.dart';
import 'role_play_state.dart';

/// Drives the Role-play experience: auto-play of the other character's lines
/// → stop at the user's turn → wait for a passing speech attempt → advance.
///
/// Explicit non-goals (per TASK 13 §scope):
///   • No persistent storage. [results] lives only for the lifetime of this
///     bloc; closing the screen drops them.
///   • No progress-marker writes to `user.db`. This feature isn't a lesson.
///   • Mic / assessment stays in [SentencePracticeBloc] — this bloc never
///     touches the speech engine directly. The player screen is responsible
///     for forwarding the assessment via [RolePlayUserAttemptResult].
@injectable
class RolePlayBloc extends Bloc<RolePlayEvent, RolePlayState> {
  final GetConversationLines _getLines;
  final SoundPlayer _soundPlayer;

  StreamSubscription<SoundSource>? _completionSub;

  /// Short visual pause between showing the passing ✓ and auto-advancing to
  /// the next line (TASK 13 §3 step 6). Exposed as a static so tests can
  /// `Future.delayed` past it deterministically.
  static const Duration passFlashDelay = Duration(milliseconds: 500);

  RolePlayBloc(this._getLines, this._soundPlayer)
      : super(const RolePlayState()) {
    on<LoadRolePlay>(_onLoad);
    on<RolePlayAudioCompleted>(_onAudioCompleted);
    on<RolePlayPreviewUserLine>(_onPreview);
    on<RolePlayStartUserMic>(_onStartMic);
    on<RolePlayStopUserMic>(_onStopMic);
    on<RolePlayUserAttemptResult>(_onAttemptResult);
    on<RolePlaySkipLine>(_onSkipLine);
    on<RolePlayRestart>(_onRestart);

    _completionSub = _soundPlayer.completionStream.listen((_) {
      if (state.playingLineId != null) {
        add(const RolePlayAudioCompleted());
      }
    });
  }

  Future<void> _onLoad(
    LoadRolePlay event,
    Emitter<RolePlayState> emit,
  ) async {
    emit(state.copyWith(
      phase: RolePlayPhase.loading,
      selectedCharacter: event.character,
      clearError: true,
    ));
    final result = await _getLines.execute(lessonId: event.lessonId);
    await result.fold(
      (err) async => emit(state.copyWith(
        phase: RolePlayPhase.error,
        errorMessage: err.toString(),
      )),
      (lines) async {
        emit(state.copyWith(
          lines: lines,
          currentIndex: 0,
          results: const {},
        ));
        await _advanceFrom(0, emit: emit);
      },
    );
  }

  Future<void> _onAudioCompleted(
    RolePlayAudioCompleted event,
    Emitter<RolePlayState> emit,
  ) async {
    // Preview playback for the user's own line — stay in waitingForUser.
    if (state.phase == RolePlayPhase.waitingForUser) {
      emit(state.copyWith(clearPlaying: true));
      return;
    }
    // Non-user line finished → move the pointer forward.
    if (state.phase == RolePlayPhase.autoPlaying) {
      await _advanceFrom(state.currentIndex + 1, emit: emit);
      return;
    }
  }

  Future<void> _onPreview(
    RolePlayPreviewUserLine event,
    Emitter<RolePlayState> emit,
  ) async {
    if (state.phase != RolePlayPhase.waitingForUser) return;
    final line = state.currentLine;
    if (line == null) return;
    // Tap again while previewing → stop.
    if (state.playingLineId == line.id) {
      await _soundPlayer.stop();
      emit(state.copyWith(clearPlaying: true));
      return;
    }
    await _playLine(line, emit: emit);
  }

  Future<void> _onStartMic(
    RolePlayStartUserMic event,
    Emitter<RolePlayState> emit,
  ) async {
    if (state.phase != RolePlayPhase.waitingForUser) return;
    // Stop any in-flight preview so the mic doesn't record our own audio.
    if (state.playingLineId != null) {
      await _soundPlayer.stop();
    }
    emit(state.copyWith(phase: RolePlayPhase.checking, clearPlaying: true));
  }

  Future<void> _onStopMic(
    RolePlayStopUserMic event,
    Emitter<RolePlayState> emit,
  ) async {
    if (state.phase != RolePlayPhase.checking) return;
    emit(state.copyWith(phase: RolePlayPhase.waitingForUser));
  }

  Future<void> _onAttemptResult(
    RolePlayUserAttemptResult event,
    Emitter<RolePlayState> emit,
  ) async {
    final line = state.currentLine;
    if (line == null || line.id != event.lineId) {
      debugPrint(
        '🎭 RolePlay attempt for line ${event.lineId} but current line is '
        '${line?.id} — ignoring.',
      );
      return;
    }
    final previous = state.results[line.id];
    final newAttempts = (previous?.attempts ?? 0) + 1;
    final passedNow = event.assessment.passed;
    final newBest = (previous == null)
        ? event.assessment.score
        : (event.assessment.score > previous.bestScore
            ? event.assessment.score
            : previous.bestScore);
    // passedFirstTry is "true if the attempt that passed was the first one"
    // — don't clobber a previous true with a later retry.
    final passedFirst = previous?.passedFirstTry ??
        (passedNow && newAttempts == 1);

    final updatedResults = Map<int, RoleLineResult>.from(state.results);

    if (!passedNow) {
      // Record the attempt (bumps the counter + bestScore) and return to
      // waitingForUser so the user can retry immediately. No cap.
      updatedResults[line.id] = RoleLineResult(
        bestScore: newBest,
        attempts: newAttempts,
        passedFirstTry: false,
      );
      emit(state.copyWith(
        phase: RolePlayPhase.waitingForUser,
        results: updatedResults,
      ));
      return;
    }

    // Passing attempt — flash a brief ✓ then auto-advance.
    updatedResults[line.id] = RoleLineResult(
      bestScore: newBest,
      attempts: newAttempts,
      passedFirstTry: passedFirst,
    );
    emit(state.copyWith(
      phase: RolePlayPhase.passed,
      results: updatedResults,
    ));
    await Future<void>.delayed(passFlashDelay);
    if (isClosed) return;
    await _advanceFrom(state.currentIndex + 1, emit: emit);
  }

  /// Failed attempts on a line before "Skip this line" is offered.
  static const int skipAfterAttempts = 2;

  Future<void> _onSkipLine(
    RolePlaySkipLine event,
    Emitter<RolePlayState> emit,
  ) async {
    if (state.phase != RolePlayPhase.waitingForUser) return;
    final line = state.currentLine;
    if (line == null) return;
    final previous = state.results[line.id];
    final updatedResults = Map<int, RoleLineResult>.from(state.results);
    updatedResults[line.id] = RoleLineResult(
      bestScore: previous?.bestScore ?? 0,
      attempts: previous?.attempts ?? 0,
      passedFirstTry: false,
      skipped: true,
    );
    emit(state.copyWith(results: updatedResults));
    await _advanceFrom(state.currentIndex + 1, emit: emit);
  }

  Future<void> _onRestart(
    RolePlayRestart event,
    Emitter<RolePlayState> emit,
  ) async {
    await _soundPlayer.stop();
    emit(state.copyWith(
      phase: RolePlayPhase.loading,
      currentIndex: 0,
      results: const {},
      clearPlaying: true,
      clearError: true,
    ));
    await _advanceFrom(0, emit: emit);
  }

  /// Moves the pointer to [newIndex] and either starts playing (non-user
  /// line), waits for the mic (user line), or declares the lesson finished.
  Future<void> _advanceFrom(
    int newIndex, {
    required Emitter<RolePlayState> emit,
  }) async {
    if (newIndex >= state.lines.length) {
      await _soundPlayer.stop();
      emit(state.copyWith(
        phase: RolePlayPhase.finished,
        currentIndex: state.lines.length,
        clearPlaying: true,
      ));
      return;
    }
    final nextLine = state.lines[newIndex];
    if (nextLine.character == state.selectedCharacter) {
      // User's turn — stop any audio, pin the pointer, wait.
      await _soundPlayer.stop();
      emit(state.copyWith(
        phase: RolePlayPhase.waitingForUser,
        currentIndex: newIndex,
        clearPlaying: true,
      ));
      return;
    }
    // Another character — advance pointer and start audio. The next hop
    // happens from the completion stream.
    emit(state.copyWith(
      phase: RolePlayPhase.autoPlaying,
      currentIndex: newIndex,
    ));
    await _playLine(nextLine, emit: emit);
  }

  Future<void> _playLine(
    ConversationLine line, {
    required Emitter<RolePlayState> emit,
  }) async {
    final url = CdnConfig.conversationAudio(line.id, CdnConfig.currentVoice);
    debugPrint('🎭 playing line ${line.id} (${line.character}) url=$url');
    emit(state.copyWith(playingLineId: line.id));
    try {
      await _soundPlayer.play(
        cdnUrl: url,
        fallbackText: line.english,
      );
    } catch (e, st) {
      debugPrint('🎭 play threw for line ${line.id}: $e\n$st');
      emit(state.copyWith(
        clearPlaying: true,
        errorMessage: 'Playback failed.',
      ));
    }
  }

  @override
  Future<void> close() async {
    await _completionSub?.cancel();
    await _soundPlayer.stop();
    return super.close();
  }
}
