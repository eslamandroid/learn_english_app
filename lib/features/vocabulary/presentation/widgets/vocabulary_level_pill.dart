import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/enums/cefr_level.dart';

/// Rounded pill showing the CEFR level ("A2 LEVEL") in the level's tint —
/// used above the topics grid.
class VocabularyLevelPill extends StatelessWidget {
  final CefrLevel level;

  const VocabularyLevelPill({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: level.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        '${level.label} LEVEL',
        style: BayanTypography.labelMedium.copyWith(
          color: level.color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
