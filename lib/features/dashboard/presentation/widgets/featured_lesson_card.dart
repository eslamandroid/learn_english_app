import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/widgets/arabic_visibility.dart';

/// "Daily Commute"-style hero card from the dashboard mockup — module tag,
/// title (bilingual), progress, Continue Lesson button. Generic enough that
/// any module can drive it.
class FeaturedLessonCard extends StatelessWidget {
  final String moduleTag;
  final String title;
  final String? titleAr;
  final IconData icon;
  final double progress;
  final VoidCallback onContinue;

  const FeaturedLessonCard({
    super.key,
    required this.moduleTag,
    required this.title,
    this.titleAr,
    required this.icon,
    required this.progress,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    final ar = titleAr ?? '';
    final pct = (progress.clamp(0.0, 1.0) * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BayanColors.primary, BayanColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingSm + 2,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusFull),
                      ),
                      child: Text(
                        moduleTag.toUpperCase(),
                        style: BayanTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    Text(
                      title,
                      style: BayanTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (ar.isNotEmpty)
                      ArabicVisibility(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            ar,
                            style: BayanTypography.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.progress,
                  style: BayanTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: BayanTypography.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: BayanColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
              ),
              child: Text(
                l.continueLesson,
                style: BayanTypography.titleLarge.copyWith(
                  color: BayanColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
