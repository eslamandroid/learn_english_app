import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/audio/sound_player.dart';
import '../../../../../core/network/cdn_config.dart';
import '../../../../../core/usecases/get_selected_level.dart';
import '../../../../../core/utils/voice_preferences.dart';
import '../../../../../shared/enums/cefr_level.dart';
import '../../../domain/usecases/get_vocabulary_words.dart';
import 'vocabulary_words_event.dart';
import 'vocabulary_words_state.dart';

@injectable
class VocabularyWordsBloc
    extends Bloc<VocabularyWordsEvent, VocabularyWordsState> {
  final GetVocabularyWords _getWords;
  final SoundPlayer _soundPlayer;
  final GetSelectedLevel _getLevel;

  /// User's current CEFR level — exposed so the word-detail hero can render
  /// the level chip without threading prefs through the widget tree.
  CefrLevel get level => _getLevel.current();

  StreamSubscription<SoundSource>? _completionSub;

  VocabularyWordsBloc(this._getWords, this._soundPlayer, this._getLevel)
    : super(const VocabularyWordsInitial()) {
    on<LoadVocabularyWords>(_onLoad);
    on<PlayVocabularyWord>(_onPlay);
    on<PlayVocabularyExample>(_onPlayExample);
    on<StopVocabularyWord>(_onStop);
    on<ChangeVocabularyWordIndex>(_onChangeIndex);
    on<SetVocabularyWordAccent>(_onSetAccent);
    on<SetVocabularyWordSpeed>(_onSetSpeed);

    _completionSub = _soundPlayer.completionStream.listen((_) {
      final s = state;
      if (s is VocabularyWordsLoaded &&
          (s.playingWordId != null || s.playingExampleWordId != null)) {
        add(const StopVocabularyWord());
      }
    });
  }

  Future<void> _onLoad(
    LoadVocabularyWords event,
    Emitter<VocabularyWordsState> emit,
  ) async {
    emit(const VocabularyWordsLoading());
    final result = await _getWords.execute(subtopicId: event.subtopicId);
    result.fold(
      (e) => emit(VocabularyWordsError(message: e.toString())),
      (words) => emit(
        VocabularyWordsLoaded(
          words: words,
          accent: AppVoicePreferences.instance.accent.value,
        ),
      ),
    );
  }

  Future<void> _onPlay(
    PlayVocabularyWord event,
    Emitter<VocabularyWordsState> emit,
  ) async {
    final s = state;
    if (s is! VocabularyWordsLoaded) return;

    // Tap on the currently-playing word acts as a stop toggle.
    if (s.playingWordId == event.wordId) {
      await _soundPlayer.stop();
      emit(s.copyWith(clearPlaying: true));
      return;
    }

    final word = s.words.firstWhereOrNull((w) => w.id == event.wordId);
    if (word == null) return;

    emit(s.copyWith(clearPlaying: true).copyWith(playingWordId: event.wordId));
    await _soundPlayer.play(
      cdnUrl: CdnConfig.vocabularyAudio(word.id, _voiceKey(s.accent)),
      fallbackText: word.word,
      rate: s.speed.rate,
    );
  }

  Future<void> _onPlayExample(
    PlayVocabularyExample event,
    Emitter<VocabularyWordsState> emit,
  ) async {
    final s = state;
    if (s is! VocabularyWordsLoaded) return;

    if (s.playingExampleWordId == event.wordId) {
      await _soundPlayer.stop();
      emit(s.copyWith(clearPlaying: true));
      return;
    }

    final word = s.words.firstWhereOrNull((w) => w.id == event.wordId);
    if (word == null || word.usage.trim().isEmpty) return;

    emit(
      s
          .copyWith(clearPlaying: true)
          .copyWith(playingExampleWordId: event.wordId),
    );
    await _soundPlayer.speak(
      word.usage,
      locale: s.accent == VoiceAccent.uk ? 'en-GB' : 'en-US',
      rate: s.speed.rate,
    );
  }

  Future<void> _onStop(
    StopVocabularyWord event,
    Emitter<VocabularyWordsState> emit,
  ) async {
    await _soundPlayer.stop();
    final s = state;
    if (s is VocabularyWordsLoaded) {
      emit(s.copyWith(clearPlaying: true));
    }
  }

  Future<void> _onChangeIndex(
    ChangeVocabularyWordIndex event,
    Emitter<VocabularyWordsState> emit,
  ) async {
    final s = state;
    if (s is! VocabularyWordsLoaded) return;
    if (event.index == s.currentIndex) return;

    // Swiping to a new word cancels the current playback — playing "boy" and
    // then landing on "girl" should not keep speaking "boy".
    await _soundPlayer.stop();
    emit(s.copyWith(currentIndex: event.index, clearPlaying: true));
  }

  void _onSetAccent(
    SetVocabularyWordAccent event,
    Emitter<VocabularyWordsState> emit,
  ) {
    final s = state;
    if (s is! VocabularyWordsLoaded) return;
    if (s.accent == event.accent) return;

    // Persist so this choice also stays in sync with the Settings screen.
    AppVoicePreferences.instance.setAccent(event.accent);
    emit(s.copyWith(accent: event.accent));
  }

  void _onSetSpeed(
    SetVocabularyWordSpeed event,
    Emitter<VocabularyWordsState> emit,
  ) {
    final s = state;
    if (s is! VocabularyWordsLoaded) return;
    if (s.speed == event.speed) return;
    emit(s.copyWith(speed: event.speed));
  }

  /// Reuses the persisted gender from Settings but overrides the accent with
  /// the per-screen selection.
  String _voiceKey(VoiceAccent accent) {
    final gender = AppVoicePreferences.instance.gender.value.name;
    return '${accent.name}_$gender';
  }

  @override
  Future<void> close() async {
    await _completionSub?.cancel();
    await _soundPlayer.stop();
    return super.close();
  }
}
