import '../../domain/entities/grammar_rule_example.dart';

class GrammarRuleExampleModel extends GrammarRuleExample {
  const GrammarRuleExampleModel({
    required super.id,
    required super.descriptionId,
    required super.sortOrder,
    required super.textEn,
    super.textAr,
    super.mustHighlight,
  });

  // grammar_rule_example uses snake_case + `must_en` for highlight markup.
  factory GrammarRuleExampleModel.fromMap(Map<String, Object?> map) {
    return GrammarRuleExampleModel(
      id: map['id'] as int,
      descriptionId: map['description_id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      textEn: map['text_en'] as String? ?? '',
      textAr: map['text_ar'] as String?,
      mustHighlight: _splitHighlights(map['must_en'] as String?),
    );
  }
}

List<String> _splitHighlights(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  // `must_en` separator varies in the corpus (`,`, `|`, `;`) — split on any.
  return raw
      .split(RegExp(r'[,|;]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList(growable: false);
}
