import 'package:equatable/equatable.dart';

abstract class SentenceTopicsEvent extends Equatable {
  const SentenceTopicsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSentenceTopics extends SentenceTopicsEvent {
  const LoadSentenceTopics();
}

/// User tapped a topic header. Null closes everything (only-one-open rule).
class ToggleSentenceTopicExpanded extends SentenceTopicsEvent {
  final int? topicId;
  const ToggleSentenceTopicExpanded(this.topicId);
  @override
  List<Object?> get props => [topicId];
}

/// Internal — fires when progress rows change in the repository.
class SentenceProgressRefreshed extends SentenceTopicsEvent {
  const SentenceProgressRefreshed();
}
