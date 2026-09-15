import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../domain/entities/phonetic_section.dart';

class PhoneticProTipCard extends StatelessWidget {
  final PhoneticSection section;
  const PhoneticProTipCard({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final isWarning = section.superType == 'warning';
    final tint = isWarning ? BayanColors.error : BayanColors.tertiary;
    final title = (section.title?.isNotEmpty ?? false)
        ? section.title!
        : (isWarning ? 'Warning' : 'Pro Tip!');

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWarning
                  ? Icons.warning_amber_rounded
                  : Icons.lightbulb_rounded,
              color: tint,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: BayanTypography.titleLarge.copyWith(color: tint),
                ),
                if ((section.body ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    section.body!,
                    style: BayanTypography.bodyMedium.copyWith(
                      color: BayanColors.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
