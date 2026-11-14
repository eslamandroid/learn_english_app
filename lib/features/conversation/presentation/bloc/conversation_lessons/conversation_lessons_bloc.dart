import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../features/progress/domain/entities/conversation_progress.dart';
import '../../../../../features/progress/domain/repositories/progress_repository.dart';
import '../../../../../features/progress/domain/usecases/get_conversation_progress.dart';
import '../../../domain/usecases/get_conversation_lessons.dart';
import 'conversation_lessons_event.dart';
import 'conversation_lessons_state.dart';

@injectable
class ConversationLessonsBloc
    extends Bloc<ConversationLessonsEvent, ConversationLessonsState> {
  final GetConversationLessons _getLessons;
  final GetConversationProgress _getProgress;
  final ProgressRepository _progressRepo;

  int? _categoryId;
  StreamSubscription<void>? _changesSub;

  ConversationLessonsBloc(
    this._getLessons,
    this._getProgress,
    this._progressRepo,
  ) : super(const ConversationLessonsInitial()) {
    on<LoadConversationLessons>(_onLoad);
    on<ConversationLessonsProgressRefreshed>(_onProgressRefreshed);
  }

  Future<void> _onLoad(
    LoadConversationLessons event,
    Emitter<ConversationLessonsState> emit,
  ) async {
    _categoryId = event.categoryId;
    emit(const ConversationLessonsLoading());
    final lessonsResult =
        await _getLessons.execute(categoryId: event.categoryId);
    final progressResult = await _getProgress.execute();

    lessonsResult.fold(
      (err) => emit(ConversationLessonsError(message: err.toString())),
      (lessons) {
        final progress = progressResult
                .toOption()
                .toNullable() ??
            ConversationProgress.empty;
        emit(ConversationLessonsLoaded(lessons: lessons, progress: progress));
      },
    );

    // Watch for completed/started markers from the player — re-fetch on each.
    _changesSub ??= _progressRepo.changes.listen(
      (_) => add(const ConversationLessonsProgressRefreshed()),
    );
  }

  Future<void> _onProgressRefreshed(
    ConversationLessonsProgressRefreshed event,
    Emitter<ConversationLessonsState> emit,
  ) async {
    final s = state;
    if (s is! ConversationLessonsLoaded || _categoryId == null) return;
    final progress = await _progressRepo.getConversationProgress();
    emit(s.copyWith(progress: progress));
  }

  @override
  Future<void> close() async {
    await _changesSub?.cancel();
    return super.close();
  }
}
