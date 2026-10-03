import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:learn_english_app/core/audio/sound_player.dart';
import 'package:learn_english_app/features/dictionary/domain/entities/dictionary_word.dart';
import 'package:learn_english_app/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:learn_english_app/features/dictionary/domain/usecases/get_my_words.dart';
import 'package:learn_english_app/features/dictionary/domain/usecases/remove_word_from_my_words.dart';
import 'package:learn_english_app/features/dictionary/domain/usecases/save_word_to_my_words.dart';
import 'package:learn_english_app/features/dictionary/domain/usecases/search_dictionary_words.dart';
import 'package:learn_english_app/features/dictionary/presentation/bloc/dictionary/dictionary_bloc.dart';
import 'package:learn_english_app/features/dictionary/presentation/bloc/dictionary/dictionary_event.dart';
import 'package:learn_english_app/features/dictionary/presentation/bloc/dictionary/dictionary_state.dart';
import 'package:learn_english_app/shared/enums/cefr_level.dart';
import 'package:mocktail/mocktail.dart';

class _MockSearch extends Mock implements SearchDictionaryWords {}

class _MockSave extends Mock implements SaveWordToMyWords {}

class _MockRemove extends Mock implements RemoveWordFromMyWords {}

class _MockGetMy extends Mock implements GetMyWords {}

class _MockRepo extends Mock implements DictionaryRepository {}

class _MockSoundPlayer extends Mock implements SoundPlayer {}

class _FakeDictionaryWord extends Fake implements DictionaryWord {}

DictionaryWord _word(int id, String en, {bool saved = false}) =>
    DictionaryWord(
      id: id,
      word: en,
      arabic: 'ع',
      pronunciation: '',
      example: '',
      level: CefrLevel.a1,
      isSaved: saved,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeDictionaryWord());
  });

  late _MockSearch search;
  late _MockSave save;
  late _MockRemove remove;
  late _MockGetMy getMy;
  late _MockRepo repo;
  late _MockSoundPlayer player;

  setUp(() {
    search = _MockSearch();
    save = _MockSave();
    remove = _MockRemove();
    getMy = _MockGetMy();
    repo = _MockRepo();
    player = _MockSoundPlayer();

    when(() => repo.savedChanges)
        .thenAnswer((_) => const Stream<void>.empty());
    when(() => player.completionStream)
        .thenAnswer((_) => const Stream<SoundSource>.empty());
    when(() => player.stop()).thenAnswer((_) async {});
    when(() => player.play(
          cdnUrl: any(named: 'cdnUrl'),
          fallbackText: any(named: 'fallbackText'),
          locale: any(named: 'locale'),
          rate: any(named: 'rate'),
        )).thenAnswer((_) async => SoundSource.cdn);
    when(() => getMy.execute())
        .thenAnswer((_) async => const Right(<DictionaryWord>[]));
  });

  DictionaryBloc build() =>
      DictionaryBloc(search, save, remove, getMy, repo, player);

  blocTest<DictionaryBloc, DictionaryState>(
    'initial load → loaded state with words',
    build: () {
      when(() => search.execute(
            query: any(named: 'query'),
            level: any(named: 'level'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => Right([_word(1, 'about')]));
      return build();
    },
    act: (b) => b.add(const LoadInitialDictionary()),
    expect: () => [
      isA<DictionaryState>()
          .having((s) => s.status, 'status', DictionaryStatus.loading),
      isA<DictionaryState>()
          .having((s) => s.status, 'status', DictionaryStatus.loaded)
          .having((s) => s.words.length, 'words.length', 1),
    ],
    verify: (_) {
      verify(() => search.execute(
            query: '',
            level: null,
            limit: 50,
            offset: 0,
          )).called(1);
    },
  );

  blocTest<DictionaryBloc, DictionaryState>(
    'level change re-queries with new level',
    build: () {
      when(() => search.execute(
            query: any(named: 'query'),
            level: any(named: 'level'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => Right([_word(1, 'alpha')]));
      return build();
    },
    seed: () => const DictionaryState(status: DictionaryStatus.loaded),
    act: (b) => b.add(const DictionaryLevelChanged(CefrLevel.b1)),
    verify: (_) {
      verify(() => search.execute(
            query: '',
            level: CefrLevel.b1,
            limit: 50,
            offset: 0,
          )).called(1);
    },
  );

  blocTest<DictionaryBloc, DictionaryState>(
    'ToggleSaved flips isSaved optimistically and calls save/remove',
    build: () {
      when(() => save.execute(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => remove.execute(any()))
          .thenAnswer((_) async => const Right(null));
      return build();
    },
    seed: () => DictionaryState(
      status: DictionaryStatus.loaded,
      words: [_word(1, 'about', saved: false)],
    ),
    act: (b) => b.add(DictionaryToggleSaved(_word(1, 'about', saved: false))),
    expect: () => [
      isA<DictionaryState>().having(
        (s) => s.words.first.isSaved,
        'words[0].isSaved',
        true,
      ),
    ],
    verify: (_) {
      verify(() => save.execute(any())).called(1);
      verifyNever(() => remove.execute(any()));
    },
  );

  blocTest<DictionaryBloc, DictionaryState>(
    'ToggleSaved on an already-saved word calls remove, not save',
    build: () {
      when(() => save.execute(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => remove.execute(any()))
          .thenAnswer((_) async => const Right(null));
      return build();
    },
    seed: () => DictionaryState(
      status: DictionaryStatus.loaded,
      words: [_word(1, 'about', saved: true)],
    ),
    act: (b) => b.add(DictionaryToggleSaved(_word(1, 'about', saved: true))),
    expect: () => [
      isA<DictionaryState>().having(
        (s) => s.words.first.isSaved,
        'words[0].isSaved',
        false,
      ),
    ],
    verify: (_) {
      verify(() => remove.execute('about')).called(1);
      verifyNever(() => save.execute(any()));
    },
  );

  blocTest<DictionaryBloc, DictionaryState>(
    'LoadMore appends next page and tracks hasMore',
    build: () {
      final page2 = List.generate(50, (i) => _word(50 + i, 'word$i'));
      when(() => search.execute(
            query: any(named: 'query'),
            level: any(named: 'level'),
            limit: 50,
            offset: 50,
          )).thenAnswer((_) async => Right(page2));
      return build();
    },
    seed: () => DictionaryState(
      status: DictionaryStatus.loaded,
      hasMore: true,
      words: List.generate(50, (i) => _word(i, 'first$i')),
    ),
    act: (b) => b.add(const DictionaryLoadMore()),
    expect: () => [
      isA<DictionaryState>()
          .having((s) => s.status, 'status', DictionaryStatus.loadingMore),
      isA<DictionaryState>()
          .having((s) => s.status, 'status', DictionaryStatus.loaded)
          .having((s) => s.words.length, 'words.length', 100)
          .having((s) => s.hasMore, 'hasMore', true),
    ],
  );
}
