import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:learn_english_app/base/errors/uncaught/app_uncaught_exception.dart';
import 'package:learn_english_app/core/audio/sound_player.dart';
import 'package:learn_english_app/features/progress/domain/usecases/mark_sentences_subtopic_completed.dart';
import 'package:learn_english_app/features/progress/domain/usecases/mark_sentences_subtopic_started.dart';
import 'package:learn_english_app/features/progress/domain/usecases/record_sentence_seen.dart';
import 'package:learn_english_app/features/sentences/domain/entities/sentence_item.dart';
import 'package:learn_english_app/features/sentences/domain/usecases/get_sentences.dart';
import 'package:learn_english_app/features/sentences/presentation/bloc/sentence_content/sentence_content_bloc.dart';
import 'package:learn_english_app/features/sentences/presentation/bloc/sentence_content/sentence_content_event.dart';
import 'package:learn_english_app/features/sentences/presentation/bloc/sentence_content/sentence_content_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetSentences extends Mock implements GetSentences {}

class _MockSoundPlayer extends Mock implements SoundPlayer {}

class _MockStarted extends Mock implements MarkSentencesSubtopicStarted {}

class _MockCompleted extends Mock implements MarkSentencesSubtopicCompleted {}

class _MockRecordSeen extends Mock implements RecordSentenceSeen {}

void main() {
  late _MockGetSentences mockGet;
  late _MockSoundPlayer mockPlayer;
  late _MockStarted mockStarted;
  late _MockCompleted mockCompleted;
  late _MockRecordSeen mockSeen;

  setUp(() {
    mockGet = _MockGetSentences();
    mockPlayer = _MockSoundPlayer();
    mockStarted = _MockStarted();
    mockCompleted = _MockCompleted();
    mockSeen = _MockRecordSeen();

    when(() => mockPlayer.completionStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockPlayer.stop()).thenAnswer((_) async {});
    when(() => mockStarted.execute(subtopicId: any(named: 'subtopicId')))
        .thenAnswer((_) async => const Right(null));
    when(() => mockSeen.execute(
          lessonId: any(named: 'lessonId'),
          seen: any(named: 'seen'),
          total: any(named: 'total'),
        )).thenAnswer((_) async => const Right(null));
  });

  const sentence = SentenceItem(
    id: 1,
    english: 'Hi there',
    arabic: 'أهلاً',
  );

  SentenceContentBloc buildBloc() => SentenceContentBloc(
        mockGet,
        mockPlayer,
        mockStarted,
        mockCompleted,
        mockSeen,
      );

  blocTest<SentenceContentBloc, SentenceContentState>(
    'loading → loaded on success',
    build: () {
      when(() => mockGet.execute(subtopicId: any(named: 'subtopicId')))
          .thenAnswer((_) async => const Right([sentence]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadSentenceContent(subtopicId: 1)),
    expect: () => [
      const SentenceContentLoading(),
      isA<SentenceContentLoaded>()
          .having((s) => s.sentences, 'sentences', [sentence])
          .having((s) => s.isCompleted, 'isCompleted', false),
    ],
    verify: (_) {
      verify(() => mockSeen.execute(lessonId: 1, seen: 1, total: 1)).called(1);
    },
  );

  blocTest<SentenceContentBloc, SentenceContentState>(
    'loading → error on failure',
    build: () {
      when(() => mockGet.execute(subtopicId: any(named: 'subtopicId')))
          .thenAnswer((_) async => Left(AppUncaughtException('err')));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadSentenceContent(subtopicId: 1)),
    expect: () => [
      const SentenceContentLoading(),
      isA<SentenceContentError>(),
    ],
  );

  blocTest<SentenceContentBloc, SentenceContentState>(
    'MarkComplete sets isCompleted=true',
    build: () {
      when(() => mockGet.execute(subtopicId: any(named: 'subtopicId')))
          .thenAnswer((_) async => const Right([sentence]));
      when(() => mockCompleted.execute(subtopicId: any(named: 'subtopicId')))
          .thenAnswer((_) async => const Right(null));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(const LoadSentenceContent(subtopicId: 1));
      await Future.delayed(Duration.zero);
      bloc.add(const MarkSentenceContentComplete(subtopicId: 1));
    },
    expect: () => [
      const SentenceContentLoading(),
      isA<SentenceContentLoaded>()
          .having((s) => s.isCompleted, 'isCompleted', false),
      isA<SentenceContentLoaded>()
          .having((s) => s.isCompleted, 'isCompleted', true),
    ],
  );

  blocTest<SentenceContentBloc, SentenceContentState>(
    'TrackSentenceSeen is monotonic and writes once per high-water-mark',
    build: () {
      when(() => mockGet.execute(subtopicId: any(named: 'subtopicId')))
          .thenAnswer((_) async => const Right([
                sentence,
                SentenceItem(id: 2, english: 'two', arabic: ''),
                SentenceItem(id: 3, english: 'three', arabic: ''),
              ]));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(const LoadSentenceContent(subtopicId: 7));
      await Future.delayed(Duration.zero);
      bloc.add(const TrackSentenceSeen(subtopicId: 7, oneBasedIndex: 2));
      bloc.add(const TrackSentenceSeen(subtopicId: 7, oneBasedIndex: 1));
      bloc.add(const TrackSentenceSeen(subtopicId: 7, oneBasedIndex: 2));
      bloc.add(const TrackSentenceSeen(subtopicId: 7, oneBasedIndex: 3));
    },
    verify: (_) {
      verify(() => mockSeen.execute(lessonId: 7, seen: 1, total: 3)).called(1);
      verify(() => mockSeen.execute(lessonId: 7, seen: 2, total: 3)).called(1);
      verify(() => mockSeen.execute(lessonId: 7, seen: 3, total: 3)).called(1);
      verifyNoMoreInteractions(mockSeen);
    },
  );
}
