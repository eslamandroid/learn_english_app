import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import 'weekly_stat_ring.dart';

class WeeklyOverviewCard extends StatelessWidget {
  final int words;
  final int wordsGoal;
  final int lessons;
  final int lessonsGoal;
  final double hours;
  final double hoursGoal;
  final int changePercent;

  const WeeklyOverviewCard({
    super.key,
    required this.words,
    required this.wordsGoal,
    required this.lessons,
    required this.lessonsGoal,
    required this.hours,
    required this.hoursGoal,
    required this.changePercent,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.weeklyOverview,
                  style: BayanTypography.labelLarge.copyWith(
                    color: BayanColors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Icon(
                Icons.trending_up_rounded,
                size: 18,
                color: BayanColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                l.weeklyChange(changePercent),
                style: BayanTypography.labelLarge.copyWith(
                  color: BayanColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WeeklyStatRing(
                value: '$words',
                label: l.weeklyStatWords,
                progress: wordsGoal == 0 ? 0 : words / wordsGoal,
                color: BayanColors.primary,
              ),
              WeeklyStatRing(
                value: '$lessons',
                label: l.weeklyStatLessons,
                progress: lessonsGoal == 0 ? 0 : lessons / lessonsGoal,
                color: BayanColors.success,
              ),
              WeeklyStatRing(
                value: hours.toStringAsFixed(1),
                label: l.weeklyStatHours,
                progress: hoursGoal == 0 ? 0 : hours / hoursGoal,
                color: BayanColors.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
