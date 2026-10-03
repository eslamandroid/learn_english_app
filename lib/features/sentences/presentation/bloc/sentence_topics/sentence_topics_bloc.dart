import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../features/progress/domain/entities/sentences_progress.dart';
import '../../../../../features/progress/domain/repositories/progress_repository.dart';
import '../../../../../features/progress/domain/usecases/get_sentences_progress.dart';
import '../../../domain/entities/sentence_subtopic.dart';
import '../../../domain/usecases/get_all_sentence_subtopics.dart';
import '../../../domain/usecases/get_sentence_topics.dart';
import 'sentence_topics_event.dart';
import 'sentence_topics_state.dart';

@injectable
class SentenceTopicsBloc
    extends Bloc<SentenceTopicsEvent, SentenceTopicsState> {
  final GetSentenceTopics _getTopics;
  final GetAllSentenceSubtopics _getAllSubtopics;
  final GetSentencesProgress _getProgress;
  final ProgressRepository _progressRepo;

  StreamSubscription<void>? _changesSub;

  SentenceTopicsBloc(
    this._getTopics,
    this._getAllSubtopics,
    this._getProgress,
    this._progressRepo,
  ) : super(const SentenceTopicsInitial()) {
    on<LoadSentenceTopics>(_onLoad);
    on<ToggleSentenceTopicExpanded>(_onToggle);
    on<SentenceProgressRefreshed>(_onProgressRefreshed);
  }

  Future<void> _onLoad(
    LoadSentenceTopics event,
    Emitter<SentenceTopicsState> emit,
  ) async {
    emit(const SentenceTopicsLoading());
    final topicsResult = await _getTopics.execute();
    final subtopicsResult = await _getAllSubtopics.execute();
    final progressResult = await _getProgress.execute();

    final topics = topicsResult.toOption().toNullable() ?? const [];
    final allSubs = subtopicsResult.toOption().toNullable() ?? const [];
    final progress =
        progressResult.toOption().toNullable() ?? SentencesProgress.empty;

    if (topicsResult.isLeft()) {
      final err = topicsResult.swap().toOption().toNullable();
      emit(SentenceTopicsError(message: err?.toString() ?? 'Load failed'));
      return;
    }

    final grouped = <int, List<SentenceSubtopic>>{};
    for (final s in allSubs) {
      grouped.putIfAbsent(s.topicId, () => []).add(s);
    }

    emit(SentenceTopicsLoaded(
      topics: topics,
      subtopicsByTopic: grouped,
      progress: progress,
    ));

    _changesSub ??= _progressRepo.changes.listen(
      (_) => add(const SentenceProgressRefreshed()),
    );
  }

  void _onToggle(
    ToggleSentenceTopicExpanded event,
    Emitter<SentenceTopicsState> emit,
  ) {
    final s = state;
    if (s is! SentenceTopicsLoaded) return;
    if (s.expandedTopicId == event.topicId) {
      emit(s.copyWith(clearExpanded: true));
    } else {
      emit(s.copyWith(expandedTopicId: event.topicId));
    }
  }

  Future<void> _onProgressRefreshed(
    SentenceProgressRefreshed event,
    Emitter<SentenceTopicsState> emit,
  ) async {
    final s = state;
    if (s is! SentenceTopicsLoaded) return;
    final progress = await _progressRepo.getSentencesProgress();
    emit(s.copyWith(progress: progress));
  }

  @override
  Future<void> close() async {
    await _changesSub?.cancel();
    return super.close();
  }
}
