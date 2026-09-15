import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/enums/cefr_level.dart';
import '../../../../shared/widgets/arabic_visibility.dart';

class PhoneticsPageHeader extends StatelessWidget {
  final CefrLevel level;

  const PhoneticsPageHeader({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: BayanColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
          child: Text(
            'LEVEL ${level.label}',
            style: BayanTypography.labelMedium.copyWith(
              color: BayanColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text('Phonetics', style: BayanTypography.headlineLarge),
        const SizedBox(height: AppConstants.spacingSm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Select a category to start practicing',
                style: BayanTypography.bodyMedium.copyWith(
                  color: BayanColors.textPrimary,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
            ArabicVisibility(
              child: Padding(
                padding: const EdgeInsets.only(left: AppConstants.spacingMd),
                child: Text(
                  'علم الصوتيات',
                  style: BayanTypography.bodyMedium.copyWith(
                    color: BayanColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontFamily: BayanTypography.arabicFontFamily,

                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
