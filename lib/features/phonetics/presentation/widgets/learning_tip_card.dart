import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/enums/cefr_level.dart';

/// CEFR-level-aware learning tip shown at the bottom of the categories list.
class LearningTipCard extends StatelessWidget {
  final CefrLevel level;

  const LearningTipCard({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: BayanColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: BayanColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: BayanColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Tip',
                  style: BayanTypography.titleLarge.copyWith(
                    color: BayanColors.primary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXs),
                Text(
                  _tipForLevel(level),
                  style: BayanTypography.bodyMedium.copyWith(
                    color: BayanColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _tipForLevel(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1:
        return 'Mastering phonetic sounds helps you start speaking confidently from day one in Level A1.';
      case CefrLevel.a2:
        return 'Mastering phonetic sounds helps improve your accent and listening comprehension significantly in Level A2.';
      case CefrLevel.b1:
        return 'Refining your pronunciation in Level B1 will make conversations flow more naturally.';
      case CefrLevel.b2:
        return 'Subtle phonetic nuances in Level B2 polish your accent toward near-native clarity.';
      case CefrLevel.c1:
        return 'At Level C1, phonetic precision separates fluent speakers from natives.';
      case CefrLevel.c2:
        return 'Continue refining edge-case sounds at Level C2 to maintain native-like fluency.';
    }
  }
}
