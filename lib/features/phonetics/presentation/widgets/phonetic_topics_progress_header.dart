import 'package:flutter/material.dart';

import '../../../../base/extensions/context_ext.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/enums/cefr_level.dart';

/// Header block for the phonetic topics screen — level pill, linear progress
/// bar, and "X of Y completed" caption. Mirrors the mockup's hero strip above
/// the topic grid.
class PhoneticTopicsProgressHeader extends StatelessWidget {
  final CefrLevel level;
  final int completedCount;
  final int totalCount;

  const PhoneticTopicsProgressHeader({
    super.key,
    required this.level,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.containerPadding,
        AppConstants.spacingSm,
        AppConstants.containerPadding,
        AppConstants.spacingMd,
      ),
      child: Column(
        children: [
          _LevelPill(
            label: l.phoneticsLevelPill(
              level.id,
              level.description.toUpperCase(),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: BayanColors.surfaceContainerHigh,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(BayanColors.primary),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            l.phoneticsTopicsCompleted(completedCount, totalCount),
            textAlign: TextAlign.center,
            style: BayanTypography.bodyMedium.copyWith(
              color: BayanColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  final String label;
  const _LevelPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: BayanColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        label,
        style: BayanTypography.labelLarge.copyWith(
          color: BayanColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
