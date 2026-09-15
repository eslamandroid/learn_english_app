import 'package:equatable/equatable.dart';

class GrammarRuleTest extends Equatable {
  final int id;
  final int ruleId;
  final String question;
  final List<String> options;
  final String correct;

  const GrammarRuleTest({
    required this.id,
    required this.ruleId,
    required this.question,
    required this.options,
    required this.correct,
  });

  bool isCorrect(String answer) => answer == correct;

  @override
  List<Object?> get props => [id, ruleId, question, options, correct];
}
