import 'package:equatable/equatable.dart';

import '../../../domain/entities/grammar_rule_example.dart';
import '../../../domain/entities/grammar_rule_test.dart';

abstract class GrammarLessonEvent extends Equatable {
  const GrammarLessonEvent();

  @override
  List<Object?> get props => [];
}

class LoadGrammarLesson extends GrammarLessonEvent {
  final int subtopicId;
  const LoadGrammarLesson({required this.subtopicId});

  @override
  List<Object?> get props => [subtopicId];
}

class GoToRule extends GrammarLessonEvent {
  final int index;
  const GoToRule({required this.index});

  @override
  List<Object?> get props => [index];
}

class NextRule extends GrammarLessonEvent {
  const NextRule();
}

class PreviousRule extends GrammarLessonEvent {
  const PreviousRule();
}

/// User tapped "Finish Lesson" on the last rule — flips the lesson to
/// completed in the progress store.
class FinishLesson extends GrammarLessonEvent {
  const FinishLesson();
}

class AnswerTest extends GrammarLessonEvent {
  final GrammarRuleTest test;
  final String option;
  const AnswerTest({required this.test, required this.option});

  @override
  List<Object?> get props => [test, option];
}

class SpeakExample extends GrammarLessonEvent {
  final GrammarRuleExample example;
  const SpeakExample({required this.example});

  @override
  List<Object?> get props => [example];
}

class SilenceExample extends GrammarLessonEvent {
  const SilenceExample();
}
