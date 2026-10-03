import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/audio/sound_player.dart';
import '../../../../../core/network/cdn_config.dart';
import '../../../domain/repositories/dictionary_repository.dart';
import '../../../domain/usecases/get_my_words.dart';
import '../../../domain/usecases/remove_word_from_my_words.dart';
import '../../../domain/usecases/save_word_to_my_words.dart';
import '../../../domain/usecases/search_dictionary_words.dart';
import 'dictionary_event.dart';
import 'dictionary_state.dart';

@injectable
class DictionaryBloc extends Bloc<DictionaryEvent, DictionaryState> {
  final SearchDictionaryWords _search;
  final SaveWordToMyWords _save;
  final RemoveWordFromMyWords _remove;
  final GetMyWords _getMyWords;
  final DictionaryRepository _repo;
  final SoundPlayer _soundPlayer;

  static const _pageSize = 50;

  StreamSubscription<void>? _savedSub;
  StreamSubscription<SoundSource>? _completionSub;

  DictionaryBloc(
    this._search,
    this._save,
    this._remove,
    this._getMyWords,
    this._repo,
    this._soundPlayer,
  ) : super(const DictionaryState()) {
    // Default sequential transformer is fine here: the search bar already
    // debounces 300ms before dispatching, and DB round-trips are cheap.
    on<LoadInitialDictionary>(_onInitial);
    on<DictionaryQueryChanged>(_onQueryChanged);
    on<DictionaryLevelChanged>(_onLevelChanged);
    on<DictionaryLoadMore>(_onLoadMore);
    on<DictionaryToggleSaved>(_onToggleSaved);
    on<DictionaryPlayAudio>(_onPlay);
    on<DictionaryStopAudio>(_onStop);
    on<DictionarySavedSetRefreshed>(_onSavedRefreshed);

    _savedSub = _repo.savedChanges.listen(
      (_) => add(const DictionarySavedSetRefreshed()),
    );
    _completionSub = _soundPlayer.completionStream.listen((_) {
      if (state.playingWordId != null) add(const DictionaryStopAudio());
    });
  }

  Future<void> _onInitial(
    LoadInitialDictionary event,
    Emitter<DictionaryState> emit,
  ) async {
    emit(state.copyWith(status: DictionaryStatus.loading, clearError: true));
    await _fetchFirstPage(emit);
    await _refreshMyWordsCount(emit);
  }

  Future<void> _onQueryChanged(
    DictionaryQueryChanged event,
    Emitter<DictionaryState> emit,
  ) async {
    emit(state.copyWith(
      query: event.query,
      status: DictionaryStatus.loading,
      clearError: true,
    ));
    await _fetchFirstPage(emit);
  }

  Future<void> _onLevelChanged(
    DictionaryLevelChanged event,
    Emitter<DictionaryState> emit,
  ) async {
    emit(state.copyWith(
      level: event.level,
      clearLevel: event.level == null,
      status: DictionaryStatus.loading,
      clearError: true,
    ));
    await _fetchFirstPage(emit);
  }

  Future<void> _fetchFirstPage(Emitter<DictionaryState> emit) async {
    final result = await _search.execute(
      query: state.query,
      level: state.level,
      limit: _pageSize,
      offset: 0,
    );
    result.fold(
      (err) => emit(state.copyWith(
        status: DictionaryStatus.error,
        errorMessage: err.toString(),
      )),
      (words) => emit(state.copyWith(
        status: DictionaryStatus.loaded,
        words: words,
        hasMore: words.length == _pageSize,
      )),
    );
  }

  Future<void> _onLoadMore(
    DictionaryLoadMore event,
    Emitter<DictionaryState> emit,
  ) async {
    if (!state.hasMore || state.status == DictionaryStatus.loadingMore) return;
    emit(state.copyWith(status: DictionaryStatus.loadingMore));
    final result = await _search.execute(
      query: state.query,
      level: state.level,
      limit: _pageSize,
      offset: state.words.length,
    );
    result.fold(
      (err) => emit(state.copyWith(
        status: DictionaryStatus.error,
        errorMessage: err.toString(),
      )),
      (next) => emit(state.copyWith(
        status: DictionaryStatus.loaded,
        words: [...state.words, ...next],
        hasMore: next.length == _pageSize,
      )),
    );
  }

  Future<void> _onToggleSaved(
    DictionaryToggleSaved event,
    Emitter<DictionaryState> emit,
  ) async {
    // Optimistic flip — UI gets instant feedback.
    final nextWords = state.words
        .map((w) => w.id == event.word.id
            ? w.copyWith(isSaved: !event.word.isSaved)
            : w)
        .toList(growable: false);
    emit(state.copyWith(words: nextWords));

    if (event.word.isSaved) {
      await _remove.execute(event.word.word);
    } else {
      await _save.execute(event.word);
    }
    // Count refreshes on repository change signal.
  }

  Future<void> _onSavedRefreshed(
    DictionarySavedSetRefreshed event,
    Emitter<DictionaryState> emit,
  ) async {
    await _refreshMyWordsCount(emit);
    // Re-fetch current page saved flags so the UI stays authoritative even if
    // the sheet removed a word that's visible in the main list.
    final result = await _search.execute(
      query: state.query,
      level: state.level,
      limit: state.words.length.clamp(_pageSize, 500),
      offset: 0,
    );
    result.fold(
      (_) {},
      (fresh) => emit(state.copyWith(words: fresh)),
    );
  }

  Future<void> _refreshMyWordsCount(Emitter<DictionaryState> emit) async {
    final result = await _getMyWords.execute();
    result.fold(
      (_) {},
      (list) => emit(state.copyWith(myWordsCount: list.length)),
    );
  }

  Future<void> _onPlay(
    DictionaryPlayAudio event,
    Emitter<DictionaryState> emit,
  ) async {
    if (state.playingWordId == event.word.id) {
      await _soundPlayer.stop();
      emit(state.copyWith(clearPlaying: true));
      return;
    }
    emit(state.copyWith(playingWordId: event.word.id));
    await _soundPlayer.play(
      cdnUrl: CdnConfig.wordListAudio(event.word.id, CdnConfig.currentVoice),
      fallbackText: event.word.word,
    );
  }

  Future<void> _onStop(
    DictionaryStopAudio event,
    Emitter<DictionaryState> emit,
  ) async {
    await _soundPlayer.stop();
    emit(state.copyWith(clearPlaying: true));
  }

  @override
  Future<void> close() async {
    await _savedSub?.cancel();
    await _completionSub?.cancel();
    await _soundPlayer.stop();
    return super.close();
  }
}
