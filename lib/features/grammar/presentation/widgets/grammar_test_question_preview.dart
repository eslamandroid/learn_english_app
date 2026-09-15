import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../domain/entities/grammar_rule_test.dart';

/// Read-only preview card for one rule-level test — numbered question + bullet
/// list of options. Used by the (stub) `GrammarTestScreen` until full quiz
/// scoring lands.
class GrammarTestQuestionPreview extends StatelessWidget {
  final int index; // 1-based
  final GrammarRuleTest test;

  const GrammarTestQuestionPreview({
    super.key,
    required this.index,
    required this.test,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.localization.questionLine(index, test.question),
            style: BayanTypography.titleLarge,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          for (final option in test.options)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• $option',
                style: BayanTypography.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
