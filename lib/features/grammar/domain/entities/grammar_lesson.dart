import 'package:equatable/equatable.dart';

import 'grammar_rule.dart';
import 'grammar_subtopic.dart';

/// Fully-hydrated subtopic content: subtopic metadata + every rule with its
/// nested descriptions and examples. This is what the lesson screen renders.
class GrammarLesson extends Equatable {
  final GrammarSubtopic subtopic;
  final List<GrammarRule> rules;

  const GrammarLesson({required this.subtopic, required this.rules});

  @override
  List<Object?> get props => [subtopic, rules];
}
