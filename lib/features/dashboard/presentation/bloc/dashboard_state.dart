import 'package:equatable/equatable.dart';

import '../../../progress/domain/entities/current_grammar_lesson.dart';
import '../../domain/entities/dashboard_stats.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;

  /// The "continue" lesson surfaced by the dashboard's featured card. Null
  /// when the user has completed every grammar lesson.
  final CurrentGrammarLesson? currentGrammarLesson;

  const DashboardLoaded({
    required this.stats,
    this.currentGrammarLesson,
  });

  @override
  List<Object?> get props => [stats, currentGrammarLesson];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
