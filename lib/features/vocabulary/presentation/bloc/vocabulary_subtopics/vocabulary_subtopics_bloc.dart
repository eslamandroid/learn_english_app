import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/get_vocabulary_subtopics.dart';
import 'vocabulary_subtopics_event.dart';
import 'vocabulary_subtopics_state.dart';

@injectable
class VocabularySubtopicsBloc
    extends Bloc<VocabularySubtopicsEvent, VocabularySubtopicsState> {
  final GetVocabularySubtopics _getSubtopics;

  VocabularySubtopicsBloc(this._getSubtopics)
      : super(const VocabularySubtopicsInitial()) {
    on<LoadVocabularySubtopics>(_onLoad);
  }

  Future<void> _onLoad(
    LoadVocabularySubtopics event,
    Emitter<VocabularySubtopicsState> emit,
  ) async {
    emit(const VocabularySubtopicsLoading());
    final result = await _getSubtopics.execute(topicId: event.topicId);
    result.fold(
      (e) => emit(VocabularySubtopicsError(message: e.toString())),
      (subtopics) => emit(VocabularySubtopicsLoaded(subtopics: subtopics)),
    );
  }
}
