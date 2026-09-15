import 'package:equatable/equatable.dart';

import '../../../domain/entities/grammar_lesson.dart';
import '../../../domain/entities/grammar_rule.dart';
import '../../../domain/entities/grammar_rule_test.dart';

abstract class GrammarLessonState extends Equatable {
  const GrammarLessonState();

  @override
  List<Object?> get props => [];
}

class GrammarLessonInitial extends GrammarLessonState {
  const GrammarLessonInitial();
}

class GrammarLessonLoading extends GrammarLessonState {
  const GrammarLessonLoading();
}

class GrammarLessonError extends GrammarLessonState {
  final String message;
  const GrammarLessonError({required this.message});

  @override
  List<Object?> get props => [message];
}

class GrammarLessonLoaded extends GrammarLessonState {
  final GrammarLesson lesson;
  final List<GrammarRuleTest> tests; // all rule-level tests for the subtopic
  final int currentRuleIndex;

  /// Test id → option the user picked. Stays sticky across rule navigation
  /// so the user can review previously-answered questions.
  final Map<int, String> answers;

  /// Example currently being spoken via TTS (null when silent).
  final int? speakingExampleId;

  const GrammarLessonLoaded({
    required this.lesson,
    required this.tests,
    required this.currentRuleIndex,
    this.answers = const {},
    this.speakingExampleId,
  });

  GrammarRule get currentRule => lesson.rules[currentRuleIndex];

  /// First test scoped to the current rule, or null if the rule has none.
  GrammarRuleTest? get currentRuleTest {
    final ruleId = currentRule.id;
    for (final t in tests) {
      if (t.ruleId == ruleId) return t;
    }
    return null;
  }

  bool get hasPrev => currentRuleIndex > 0;
  bool get hasNext => currentRuleIndex < lesson.rules.length - 1;
  double get progress => lesson.rules.isEmpty
      ? 0.0
      : (currentRuleIndex + 1) / lesson.rules.length;

  GrammarLessonLoaded copyWith({
    int? currentRuleIndex,
    Map<int, String>? answers,
    int? speakingExampleId,
    bool clearSpeakingExample = false,
  }) {
    return GrammarLessonLoaded(
      lesson: lesson,
      tests: tests,
      currentRuleIndex: currentRuleIndex ?? this.currentRuleIndex,
      answers: answers ?? this.answers,
      speakingExampleId: clearSpeakingExample
          ? null
          : (speakingExampleId ?? this.speakingExampleId),
    );
  }

  @override
  List<Object?> get props => [
        lesson,
        tests,
        currentRuleIndex,
        answers,
        speakingExampleId,
      ];
}
