import 'dart:convert';

import '../../domain/entities/grammar_rule_test.dart';

class GrammarRuleTestModel extends GrammarRuleTest {
  const GrammarRuleTestModel({
    required super.id,
    required super.ruleId,
    required super.question,
    required super.options,
    required super.correct,
  });

  factory GrammarRuleTestModel.fromMap(Map<String, Object?> map) {
    return GrammarRuleTestModel(
      id: map['id'] as int,
      ruleId: map['rule_id'] as int,
      question: map['question'] as String? ?? '',
      options: _parseOptions(map['options']),
      correct: map['correct'] as String? ?? '',
    );
  }
}

List<String> _parseOptions(Object? raw) {
  if (raw is! String || raw.isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    }
  } catch (_) {
    // fall through — non-JSON payloads return empty
  }
  return const [];
}
