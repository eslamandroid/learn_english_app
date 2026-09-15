import 'package:equatable/equatable.dart';

import '../../../../progress/domain/entities/grammar_progress.dart';

abstract class GrammarTopicsEvent extends Equatable {
  const GrammarTopicsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGrammarTopics extends GrammarTopicsEvent {
  /// Pass `null` to load all topics; otherwise only topics belonging to that
  /// CEFR level (1..6) are returned.
  final int? levelId;
  const LoadGrammarTopics({this.levelId});

  @override
  List<Object?> get props => [levelId];
}

class ToggleTopicExpansion extends GrammarTopicsEvent {
  final int topicId;
  const ToggleTopicExpansion({required this.topicId});

  @override
  List<Object?> get props => [topicId];
}

/// Internal event — fired by the bloc itself in response to the progress
/// stream emitting. Carries the fresh snapshot so the bloc reducer is pure.
class ProgressChanged extends GrammarTopicsEvent {
  final GrammarProgress progress;
  const ProgressChanged({required this.progress});

  @override
  List<Object?> get props => [progress];
}
