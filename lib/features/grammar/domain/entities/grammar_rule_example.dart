import 'package:equatable/equatable.dart';

class GrammarRuleExample extends Equatable {
  final int id;
  final int descriptionId;
  final int sortOrder;
  final String textEn;
  final String? textAr;

  /// Words / fragments inside [textEn] that should be visually highlighted.
  /// Stored in the DB as a separator-delimited string; the model splits it.
  final List<String> mustHighlight;

  const GrammarRuleExample({
    required this.id,
    required this.descriptionId,
    required this.sortOrder,
    required this.textEn,
    this.textAr,
    this.mustHighlight = const [],
  });

  @override
  List<Object?> get props =>
      [id, descriptionId, sortOrder, textEn, textAr, mustHighlight];
}
