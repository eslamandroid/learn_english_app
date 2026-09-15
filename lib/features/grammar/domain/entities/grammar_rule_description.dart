import 'package:equatable/equatable.dart';

import 'grammar_rule_example.dart';

class GrammarRuleDescription extends Equatable {
  final int id;
  final int ruleId;
  final int sortOrder;
  final String? textEn;
  final String? textAr;
  final List<String> mustHighlight;
  final String? image;
  final List<GrammarRuleExample> examples;

  const GrammarRuleDescription({
    required this.id,
    required this.ruleId,
    required this.sortOrder,
    this.textEn,
    this.textAr,
    this.mustHighlight = const [],
    this.image,
    this.examples = const [],
  });

  @override
  List<Object?> get props => [
        id,
        ruleId,
        sortOrder,
        textEn,
        textAr,
        mustHighlight,
        image,
        examples,
      ];
}
