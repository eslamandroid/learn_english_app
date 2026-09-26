import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/get_selected_level.dart';
import '../../../../../shared/enums/cefr_level.dart';
import '../../../domain/usecases/get_vocabulary_topics.dart';
import 'vocabulary_topics_event.dart';
import 'vocabulary_topics_state.dart';

@injectable
class VocabularyTopicsBloc
    extends Bloc<VocabularyTopicsEvent, VocabularyTopicsState> {
  final GetVocabularyTopics _getTopics;
  final GetSelectedLevel _getLevel;

  /// The user's current CEFR level — exposed so the screen header can render
  /// the level chip without touching prefs directly.
  CefrLevel get level => _getLevel.current();

  VocabularyTopicsBloc(this._getTopics, this._getLevel)
      : super(const VocabularyTopicsInitial()) {
    on<LoadVocabularyTopics>(_onLoad);
  }

  Future<void> _onLoad(
    LoadVocabularyTopics event,
    Emitter<VocabularyTopicsState> emit,
  ) async {
    emit(const VocabularyTopicsLoading());
    final result = await _getTopics.execute(levelId: event.levelId);
    result.fold(
      (e) => emit(VocabularyTopicsError(message: e.toString())),
      (topics) => emit(VocabularyTopicsLoaded(topics: topics)),
    );
  }
}
