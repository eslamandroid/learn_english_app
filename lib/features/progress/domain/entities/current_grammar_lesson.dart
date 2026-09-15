import 'package:equatable/equatable.dart';

import '../../../grammar/domain/entities/grammar_subtopic.dart';
import '../../../grammar/domain/entities/grammar_topic.dart';

/// The "next" or "resume" grammar lesson for the user — what the dashboard's
/// Continue card and the streak widgets focus on.
class CurrentGrammarLesson extends Equatable {
  final GrammarTopic topic;
  final GrammarSubtopic subtopic;

  /// Fraction (0.0 .. 1.0) of subtopics in [topic] the user has completed.
  final double topicProgress;

  const CurrentGrammarLesson({
    required this.topic,
    required this.subtopic,
    required this.topicProgress,
  });

  @override
  List<Object?> get props => [topic, subtopic, topicProgress];
}
