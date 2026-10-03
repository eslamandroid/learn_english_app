import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:learn_english_app/base/errors/uncaught/app_uncaught_exception.dart';
import 'package:learn_english_app/features/progress/domain/entities/sentences_progress.dart';
import 'package:learn_english_app/features/progress/domain/repositories/progress_repository.dart';
import 'package:learn_english_app/features/progress/domain/usecases/get_sentences_progress.dart';
import 'package:learn_english_app/features/sentences/domain/entities/sentence_subtopic.dart';
import 'package:learn_english_app/features/sentences/domain/entities/sentence_topic.dart';
import 'package:learn_english_app/features/sentences/domain/usecases/get_all_sentence_subtopics.dart';
import 'package:learn_english_app/features/sentences/domain/usecases/get_sentence_topics.dart';
import 'package:learn_english_app/features/sentences/presentation/bloc/sentence_topics/sentence_topics_bloc.dart';
import 'package:learn_english_app/features/sentences/presentation/bloc/sentence_topics/sentence_topics_event.dart';
import 'package:learn_english_app/features/sentences/presentation/bloc/sentence_topics/sentence_topics_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetTopics extends Mock implements GetSentenceTopics {}

class _MockGetAllSubtopics extends Mock implements GetAllSentenceSubtopics {}

class _MockGetProgress extends Mock implements GetSentencesProgress {}

class _MockProgressRepo extends Mock implements ProgressRepository {}

void main() {
  late _MockGetTopics mockGetTopics;
  late _MockGetAllSubtopics mockGetAllSubs;
  late _MockGetProgress mockGetProgress;
  late _MockProgressRepo mockRepo;

  setUp(() {
    mockGetTopics = _MockGetTopics();
    mockGetAllSubs = _MockGetAllSubtopics();
    mockGetProgress = _MockGetProgress();
    mockRepo = _MockProgressRepo();
    when(() => mockRepo.changes)
        .thenAnswer((_) => const Stream<void>.empty());
  });

  const topic = SentenceTopic(
    id: 1,
    title: 'Basic',
    titleAr: 'الأساسي',
    sentenceCount: 10,
  );
  const subtopic = SentenceSubtopic(
    id: 11,
    topicId: 1,
    title: 'Saying Hello',
    titleAr: 'التحية',
  );

  blocTest<SentenceTopicsBloc, SentenceTopicsState>(
    'loading → loaded on success',
    build: () {
      when(() => mockGetTopics.execute())
          .thenAnswer((_) async => const Right([topic]));
      when(() => mockGetAllSubs.execute())
          .thenAnswer((_) async => const Right([subtopic]));
      when(() => mockGetProgress.execute())
          .thenAnswer((_) async => const Right(SentencesProgress.empty));
      return SentenceTopicsBloc(
        mockGetTopics,
        mockGetAllSubs,
        mockGetProgress,
        mockRepo,
      );
    },
    act: (bloc) => bloc.add(const LoadSentenceTopics()),
    expect: () => [
      const SentenceTopicsLoading(),
      isA<SentenceTopicsLoaded>()
          .having((s) => s.topics, 'topics', [topic])
          .having((s) => s.subtopicsByTopic[1], 'subtopics[1]', [subtopic])
          .having((s) => s.progress, 'progress', SentencesProgress.empty),
    ],
  );

  blocTest<SentenceTopicsBloc, SentenceTopicsState>(
    'loading → error on failure',
    build: () {
      when(() => mockGetTopics.execute()).thenAnswer(
          (_) async => Left(AppUncaughtException('DB error')));
      when(() => mockGetAllSubs.execute())
          .thenAnswer((_) async => const Right(<SentenceSubtopic>[]));
      when(() => mockGetProgress.execute())
          .thenAnswer((_) async => const Right(SentencesProgress.empty));
      return SentenceTopicsBloc(
        mockGetTopics,
        mockGetAllSubs,
        mockGetProgress,
        mockRepo,
      );
    },
    act: (bloc) => bloc.add(const LoadSentenceTopics()),
    expect: () => [
      const SentenceTopicsLoading(),
      isA<SentenceTopicsError>(),
    ],
  );

  blocTest<SentenceTopicsBloc, SentenceTopicsState>(
    'toggle expanded sets and clears expandedTopicId',
    build: () {
      when(() => mockGetTopics.execute())
          .thenAnswer((_) async => const Right([topic]));
      when(() => mockGetAllSubs.execute())
          .thenAnswer((_) async => const Right([subtopic]));
      when(() => mockGetProgress.execute())
          .thenAnswer((_) async => const Right(SentencesProgress.empty));
      return SentenceTopicsBloc(
        mockGetTopics,
        mockGetAllSubs,
        mockGetProgress,
        mockRepo,
      );
    },
    act: (bloc) async {
      bloc.add(const LoadSentenceTopics());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ToggleSentenceTopicExpanded(1));
      bloc.add(const ToggleSentenceTopicExpanded(1));
    },
    skip: 2,
    expect: () => [
      isA<SentenceTopicsLoaded>()
          .having((s) => s.expandedTopicId, 'expandedTopicId', 1),
      isA<SentenceTopicsLoaded>()
          .having((s) => s.expandedTopicId, 'expandedTopicId', null),
    ],
  );
}
