import 'package:flutter/material.dart';

import '../../../../base/extensions/context_ext.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

/// "Current mastery" hero card surfaced at the top of a category when a topic
/// inside it is already in-progress. Shows the user what they're working on,
/// where they are in the category sequence, and how far they've come.
class PhoneticCurrentMasteryCard extends StatelessWidget {
  final String topicTitle;
  final int indexInCategory;
  final int totalInCategory;
  final double categoryProgress; // 0..1
  final VoidCallback? onTap;

  const PhoneticCurrentMasteryCard({
    super.key,
    required this.topicTitle,
    required this.indexInCategory,
    required this.totalInCategory,
    required this.categoryProgress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    final percent = (categoryProgress * 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.containerPadding,
        0,
        AppConstants.containerPadding,
        AppConstants.spacingMd,
      ),
      child: Material(
        color: BayanColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: BayanColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: BayanColors.onPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.phoneticsCurrentMastery,
                        style: BayanTypography.labelMedium.copyWith(
                          color: BayanColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.phoneticsCurrentTopicCount(
                          topicTitle,
                          indexInCategory,
                          totalInCategory,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BayanTypography.titleLarge.copyWith(
                          color: BayanColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                _ProgressRing(progress: categoryProgress, percent: percent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final int percent;

  const _ProgressRing({required this.progress, required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: BayanColors.primary.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(BayanColors.primary),
            ),
          ),
          Text(
            '$percent%',
            style: BayanTypography.labelMedium.copyWith(
              color: BayanColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
