import '../../domain/entities/grammar_rule_description.dart';
import '../../domain/entities/grammar_rule_example.dart';

class GrammarRuleDescriptionModel extends GrammarRuleDescription {
  const GrammarRuleDescriptionModel({
    required super.id,
    required super.ruleId,
    required super.sortOrder,
    super.textEn,
    super.textAr,
    super.mustHighlight,
    super.image,
    super.examples,
  });

  factory GrammarRuleDescriptionModel.fromMap(Map<String, Object?> map) {
    final mustEn = map['must_en'] as String?;
    return GrammarRuleDescriptionModel(
      id: map['id'] as int,
      ruleId: map['rule_id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      textEn: map['text_en'] as String?,
      textAr: map['text_ar'] as String?,
      mustHighlight: _splitHighlights(mustEn),
      image: map['image'] as String?,
    );
  }

  GrammarRuleDescriptionModel copyWithExamples(
    List<GrammarRuleExample> examples,
  ) {
    return GrammarRuleDescriptionModel(
      id: id,
      ruleId: ruleId,
      sortOrder: sortOrder,
      textEn: textEn,
      textAr: textAr,
      mustHighlight: mustHighlight,
      image: image,
      examples: examples,
    );
  }
}

List<String> _splitHighlights(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  return raw
      .split(RegExp(r'[,|;]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList(growable: false);
}
