import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/get_selected_level.dart';
import '../../../../shared/enums/cefr_level.dart';
import '../../../progress/domain/repositories/progress_repository.dart';
import '../../../progress/domain/usecases/get_current_grammar_lesson.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStats _getStats;
  final GetSelectedLevel _getLevel;
  final GetCurrentGrammarLesson _getCurrentLesson;
  final ProgressRepository _progressRepo;

  StreamSubscription<void>? _progressSub;

  /// Level used by the top-bar chrome while the dashboard is loading.
  CefrLevel get fallbackLevel => _getLevel.current();

  DashboardBloc(
    this._getStats,
    this._getLevel,
    this._getCurrentLesson,
    this._progressRepo,
  ) : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
    on<RefreshDashboard>(_onLoad);

    // Reload whenever the user starts / finishes a grammar lesson so the
    // Continue card and topic-level stats stay in sync.
    _progressSub =
        _progressRepo.changes.listen((_) => add(const RefreshDashboard()));
  }

  Future<void> _onLoad(
    DashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    // Only show the spinner on first load — background refreshes (e.g.
    // progress stream events) keep the existing UI on screen.
    if (state is! DashboardLoaded) {
      emit(const DashboardLoading());
    }

    final statsFut = _getStats.execute();
    final lessonFut = _getCurrentLesson.execute();

    final statsEither = await statsFut;
    final lessonEither = await lessonFut;

    statsEither.fold(
      (exception) => emit(DashboardError(message: exception.toString())),
      (stats) {
        final lesson = lessonEither.fold((_) => null, (l) => l);
        emit(DashboardLoaded(
          stats: stats,
          currentGrammarLesson: lesson,
        ));
      },
    );
  }

  @override
  Future<void> close() async {
    await _progressSub?.cancel();
    return super.close();
  }
}
