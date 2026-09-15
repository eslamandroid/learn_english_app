import '../../domain/entities/grammar_rule.dart';
import '../../domain/entities/grammar_rule_description.dart';

class GrammarRuleModel extends GrammarRule {
  const GrammarRuleModel({
    required super.id,
    required super.contentId,
    required super.sortOrder,
    super.title,
    super.image,
    super.descriptions,
  });

  factory GrammarRuleModel.fromMap(Map<String, Object?> map) {
    return GrammarRuleModel(
      id: map['id'] as int,
      contentId: map['content_id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      title: map['title'] as String?,
      image: map['image'] as String?,
    );
  }

  GrammarRuleModel copyWithDescriptions(
    List<GrammarRuleDescription> descriptions,
  ) {
    return GrammarRuleModel(
      id: id,
      contentId: contentId,
      sortOrder: sortOrder,
      title: title,
      image: image,
      descriptions: descriptions,
    );
  }
}
