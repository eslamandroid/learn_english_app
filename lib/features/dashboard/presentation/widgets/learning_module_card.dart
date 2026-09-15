import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

/// One module tile in the 2×2 dashboard grid — icon, title, tagline, and a
/// thin progress bar at the bottom.
class LearningModuleCard extends StatelessWidget {
  final String title;
  final String tagline;
  final IconData icon;
  final Color accent;
  final double progress;
  final VoidCallback onTap;

  const LearningModuleCard({
    super.key,
    required this.title,
    required this.tagline,
    required this.icon,
    required this.accent,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BayanColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const Spacer(),
              Text(
                title,
                style: BayanTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                tagline,
                style: BayanTypography.bodySmall.copyWith(
                  color: BayanColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: BayanColors.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
