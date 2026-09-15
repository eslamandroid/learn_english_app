import 'package:equatable/equatable.dart';

import 'grammar_rule_description.dart';

class GrammarRule extends Equatable {
  final int id;
  final int contentId;
  final int sortOrder;
  final String? title;
  final String? image;
  final List<GrammarRuleDescription> descriptions;

  const GrammarRule({
    required this.id,
    required this.contentId,
    required this.sortOrder,
    this.title,
    this.image,
    this.descriptions = const [],
  });

  @override
  List<Object?> get props =>
      [id, contentId, sortOrder, title, image, descriptions];
}
