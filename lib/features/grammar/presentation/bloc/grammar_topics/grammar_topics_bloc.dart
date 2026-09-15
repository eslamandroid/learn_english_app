import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/get_selected_level.dart';
import '../../../../../shared/enums/cefr_level.dart';
import '../../../../progress/domain/entities/grammar_progress.dart';
import '../../../../progress/domain/usecases/get_grammar_progress.dart';
import '../../../domain/usecases/get_grammar_subtopics.dart';
import '../../../domain/usecases/get_grammar_topics.dart';
import 'grammar_topics_event.dart';
import 'grammar_topics_state.dart';

@injectable
class GrammarTopicsBloc
    extends Bloc<GrammarTopicsEvent, GrammarTopicsState> {
  final GetGrammarTopics _getTopics;
  final GetGrammarSubtopics _getSubtopics;
  final GetGrammarProgress _getProgress;
  final GetSelectedLevel _getLevel;

  StreamSubscription<GrammarProgress>? _progressSub;

  /// The user's CEFR level — exposed so the screen can hydrate its AppBar
  /// header without depending on `SharedPreferences` directly.
  CefrLevel get level => _getLevel.current();

  GrammarTopicsBloc(
    this._getTopics,
    this._getSubtopics,
    this._getProgress,
    this._getLevel,
  ) : super(const GrammarTopicsInitial()) {
    on<LoadGrammarTopics>(_onLoad);
    on<ToggleTopicExpansion>(_onToggle);
    on<ProgressChanged>(_onProgressChanged);

    // Live progress feed — emits once on subscribe with the current snapshot
    // then again on every write. We re-dispatch as a `ProgressChanged` event
    // so the reducer stays pure.
    _progressSub = _getProgress.watch().listen(
          (p) => add(ProgressChanged(progress: p)),
        );
  }

  Future<void> _onLoad(
    LoadGrammarTopics event,
    Emitter<GrammarTopicsState> emit,
  ) async {
    emit(const GrammarTopicsLoading());
    final result = await _getTopics.execute(levelId: event.levelId);
    final progress = (await _getProgress.execute()).fold(
      (_) => GrammarProgress.empty,
      (p) => p,
    );
    result.fold(
      (exception) =>
          emit(GrammarTopicsError(message: exception.toString())),
      (topics) => emit(GrammarTopicsLoaded(
        topics: topics,
        progress: progress,
      )),
    );
  }

  Future<void> _onToggle(
    ToggleTopicExpansion event,
    Emitter<GrammarTopicsState> emit,
  ) async {
    final s = state;
    if (s is! GrammarTopicsLoaded) return;

    final id = event.topicId;
    final alreadyExpanded = s.expandedTopicIds.contains(id);
    final newExpanded = {...s.expandedTopicIds};
    if (alreadyExpanded) {
      newExpanded.remove(id);
      emit(s.copyWith(expandedTopicIds: newExpanded));
      return;
    }
    newExpanded.add(id);

    if (s.subtopicsByTopic.containsKey(id)) {
      emit(s.copyWith(expandedTopicIds: newExpanded));
      return;
    }

    emit(s.copyWith(
      expandedTopicIds: newExpanded,
      loadingTopicIds: {...s.loadingTopicIds, id},
    ));

    final result = await _getSubtopics.execute(topicId: id);
    final after = state;
    if (after is! GrammarTopicsLoaded) return;

    result.fold(
      (_) {
        emit(after.copyWith(
          loadingTopicIds: {...after.loadingTopicIds}..remove(id),
        ));
      },
      (subtopics) {
        emit(after.copyWith(
          subtopicsByTopic: {...after.subtopicsByTopic, id: subtopics},
          loadingTopicIds: {...after.loadingTopicIds}..remove(id),
        ));
      },
    );
  }

  void _onProgressChanged(
    ProgressChanged event,
    Emitter<GrammarTopicsState> emit,
  ) {
    final s = state;
    if (s is! GrammarTopicsLoaded) return;
    emit(s.copyWith(progress: event.progress));
  }

  @override
  Future<void> close() async {
    await _progressSub?.cancel();
    return super.close();
  }
}
