import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

/// Progress strip at the top of the Cards-mode screen — "Practice sentence"
/// label, "N of M" counter, 6h bar.
class LessonProgressHeader extends StatelessWidget {
  final int currentOneBased;
  final int total;

  const LessonProgressHeader({
    super.key,
    required this.currentOneBased,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : currentOneBased / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Practice sentence',
                style: BayanTypography.labelLarge.copyWith(
                  fontSize: 14,
                  color: BayanColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$currentOneBased of $total',
                style: BayanTypography.labelLarge.copyWith(
                  fontSize: 14,
                  color: BayanColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: BayanColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation(BayanColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
