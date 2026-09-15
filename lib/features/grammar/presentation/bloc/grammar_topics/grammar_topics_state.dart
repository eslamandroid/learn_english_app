import 'package:equatable/equatable.dart';

import '../../../../progress/domain/entities/grammar_progress.dart';
import '../../../domain/entities/grammar_subtopic.dart';
import '../../../domain/entities/grammar_topic.dart';

abstract class GrammarTopicsState extends Equatable {
  const GrammarTopicsState();

  @override
  List<Object?> get props => [];
}

class GrammarTopicsInitial extends GrammarTopicsState {
  const GrammarTopicsInitial();
}

class GrammarTopicsLoading extends GrammarTopicsState {
  const GrammarTopicsLoading();
}

class GrammarTopicsLoaded extends GrammarTopicsState {
  final List<GrammarTopic> topics;
  final Set<int> expandedTopicIds;
  final Map<int, List<GrammarSubtopic>> subtopicsByTopic;
  final Set<int> loadingTopicIds;
  final GrammarProgress progress;

  const GrammarTopicsLoaded({
    required this.topics,
    this.expandedTopicIds = const {},
    this.subtopicsByTopic = const {},
    this.loadingTopicIds = const {},
    this.progress = GrammarProgress.empty,
  });

  GrammarTopicsLoaded copyWith({
    List<GrammarTopic>? topics,
    Set<int>? expandedTopicIds,
    Map<int, List<GrammarSubtopic>>? subtopicsByTopic,
    Set<int>? loadingTopicIds,
    GrammarProgress? progress,
  }) {
    return GrammarTopicsLoaded(
      topics: topics ?? this.topics,
      expandedTopicIds: expandedTopicIds ?? this.expandedTopicIds,
      subtopicsByTopic: subtopicsByTopic ?? this.subtopicsByTopic,
      loadingTopicIds: loadingTopicIds ?? this.loadingTopicIds,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
        topics,
        expandedTopicIds,
        subtopicsByTopic,
        loadingTopicIds,
        progress,
      ];
}

class GrammarTopicsError extends GrammarTopicsState {
  final String message;
  const GrammarTopicsError({required this.message});

  @override
  List<Object?> get props => [message];
}
