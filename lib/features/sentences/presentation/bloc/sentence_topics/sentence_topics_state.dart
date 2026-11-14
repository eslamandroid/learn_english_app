import 'package:equatable/equatable.dart';

import '../../../../../features/progress/domain/entities/sentences_progress.dart';
import '../../../domain/entities/sentence_subtopic.dart';
import '../../../domain/entities/sentence_topic.dart';

sealed class SentenceTopicsState extends Equatable {
  const SentenceTopicsState();
  @override
  List<Object?> get props => [];
}

class SentenceTopicsInitial extends SentenceTopicsState {
  const SentenceTopicsInitial();
}

class SentenceTopicsLoading extends SentenceTopicsState {
  const SentenceTopicsLoading();
}

class SentenceTopicsLoaded extends SentenceTopicsState {
  final List<SentenceTopic> topics;
  final Map<int, List<SentenceSubtopic>> subtopicsByTopic;
  final SentencesProgress progress;
  final int? expandedTopicId;

  const SentenceTopicsLoaded({
    required this.topics,
    required this.subtopicsByTopic,
    required this.progress,
    this.expandedTopicId,
  });

  SentenceTopicsLoaded copyWith({
    List<SentenceTopic>? topics,
    Map<int, List<SentenceSubtopic>>? subtopicsByTopic,
    SentencesProgress? progress,
    int? expandedTopicId,
    bool clearExpanded = false,
  }) {
    return SentenceTopicsLoaded(
      topics: topics ?? this.topics,
      subtopicsByTopic: subtopicsByTopic ?? this.subtopicsByTopic,
      progress: progress ?? this.progress,
      expandedTopicId: clearExpanded
          ? null
          : (expandedTopicId ?? this.expandedTopicId),
    );
  }

  int get totalLessons =>
      subtopicsByTopic.values.fold(0, (acc, list) => acc + list.length);

  int get completedLessons {
    var done = 0;
    for (final list in subtopicsByTopic.values) {
      for (final s in list) {
        if (progress.isCompleted(s.id)) done++;
      }
    }
    return done;
  }

  @override
  List<Object?> get props =>
      [topics, subtopicsByTopic, progress, expandedTopicId];
}

class SentenceTopicsError extends SentenceTopicsState {
  final String message;
  const SentenceTopicsError({required this.message});
  @override
  List<Object?> get props => [message];
}
