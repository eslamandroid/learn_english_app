import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../domain/entities/phonetic_category.dart';
import 'bilingual_text.dart';

class PhoneticCategoryCard extends StatelessWidget {
  final PhoneticCategory category;
  final IconData icon;
  final double progress;
  final VoidCallback onTap;

  const PhoneticCategoryCard({
    super.key,
    required this.category,
    required this.icon,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0.0, 1.0) * 100).round();
    return Material(
      color: BayanColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: BayanColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Icon(icon, color: BayanColors.primary, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    '${category.articleCount} Units',
                    style: BayanTypography.labelLarge.copyWith(
                      color: BayanColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),
              BilingualText(
                en: category.title,
                ar: category.titleAr,
                primary: BayanTypography.headlineMedium,
                secondary: BayanTypography.bodyMedium.copyWith(
                  color: BayanColors.onSurfaceVariant,
                ),
                gap: 4,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: BayanTypography.bodySmall.copyWith(
                      color: BayanColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: BayanTypography.labelLarge.copyWith(
                      color: BayanColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingSm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: BayanColors.surfaceContainerHigh,
                  valueColor:
                      const AlwaysStoppedAnimation(BayanColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
