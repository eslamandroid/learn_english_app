import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/audio/sound_player.dart';
import '../../../../../core/network/cdn_config.dart';
import '../../../../../core/utils/voice_preferences.dart';
import '../../../../../features/progress/domain/usecases/mark_sentences_subtopic_completed.dart';
import '../../../../../features/progress/domain/usecases/mark_sentences_subtopic_started.dart';
import '../../../../../features/progress/domain/usecases/record_sentence_seen.dart';
import '../../../domain/usecases/get_sentences.dart';
import 'sentence_content_event.dart';
import 'sentence_content_state.dart';

@injectable
class SentenceContentBloc
    extends Bloc<SentenceContentEvent, SentenceContentState> {
  final GetSentences _getSentences;
  final SoundPlayer _soundPlayer;
  final MarkSentencesSubtopicStarted _markStarted;
  final MarkSentencesSubtopicCompleted _markCompleted;
  final RecordSentenceSeen _recordSeen;

  StreamSubscription<SoundSource>? _completionSub;
  int _maxSeen = 0;

  SentenceContentBloc(
    this._getSentences,
    this._soundPlayer,
    this._markStarted,
    this._markCompleted,
    this._recordSeen,
  ) : super(const SentenceContentInitial()) {
    on<LoadSentenceContent>(_onLoad);
    on<PlaySentenceAudio>(_onPlay);
    on<StopSentenceAudio>(_onStop);
    on<MarkSentenceContentComplete>(_onMarkComplete);
    on<TrackSentenceSeen>(_onTrackSeen);

    _completionSub = _soundPlayer.completionStream.listen((_) {
      final s = state;
      if (s is SentenceContentLoaded && s.playingId != null) {
        add(const StopSentenceAudio());
      }
    });
  }

  Future<void> _onLoad(
    LoadSentenceContent event,
    Emitter<SentenceContentState> emit,
  ) async {
    emit(const SentenceContentLoading());
    await _markStarted.execute(subtopicId: event.subtopicId);
    final result = await _getSentences.execute(subtopicId: event.subtopicId);
    result.fold(
      (e) => emit(SentenceContentError(message: e.toString())),
      (sentences) {
        _maxSeen = 1;
        if (sentences.isNotEmpty) {
          _recordSeen.execute(
            lessonId: event.subtopicId,
            seen: 1,
            total: sentences.length,
          );
        }
        emit(SentenceContentLoaded(sentences: sentences));
      },
    );
  }

  Future<void> _onPlay(
    PlaySentenceAudio event,
    Emitter<SentenceContentState> emit,
  ) async {
    final s = state;
    if (s is! SentenceContentLoaded) return;

    if (s.playingId == event.sentenceId) {
      await _soundPlayer.stop();
      emit(s.copyWith(clearPlaying: true));
      return;
    }

    emit(s.copyWith(clearPlaying: true).copyWith(playingId: event.sentenceId));
    await _soundPlayer.play(
      cdnUrl: CdnConfig.sentenceAudio(
        event.sentenceId,
        AppVoicePreferences.instance.voiceKey,
      ),
      fallbackText: s.sentences
              .where((i) => i.id == event.sentenceId)
              .map((i) => i.english)
              .firstOrNull ??
          '',
    );
  }

  Future<void> _onStop(
    StopSentenceAudio event,
    Emitter<SentenceContentState> emit,
  ) async {
    await _soundPlayer.stop();
    final s = state;
    if (s is SentenceContentLoaded) {
      emit(s.copyWith(clearPlaying: true));
    }
  }

  Future<void> _onMarkComplete(
    MarkSentenceContentComplete event,
    Emitter<SentenceContentState> emit,
  ) async {
    await _markCompleted.execute(subtopicId: event.subtopicId);
    final s = state;
    if (s is SentenceContentLoaded) {
      emit(s.copyWith(isCompleted: true));
    }
  }

  Future<void> _onTrackSeen(
    TrackSentenceSeen event,
    Emitter<SentenceContentState> emit,
  ) async {
    final s = state;
    if (s is! SentenceContentLoaded || s.sentences.isEmpty) return;
    if (event.oneBasedIndex <= _maxSeen) return;
    _maxSeen = event.oneBasedIndex;
    await _recordSeen.execute(
      lessonId: event.subtopicId,
      seen: _maxSeen,
      total: s.sentences.length,
    );
  }

  @override
  Future<void> close() async {
    await _completionSub?.cancel();
    await _soundPlayer.stop();
    return super.close();
  }
}
