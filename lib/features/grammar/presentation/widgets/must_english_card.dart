import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

/// Peach tip card — "Must English: …" emphasising a focal point.
class MustEnglishCard extends StatelessWidget {
  final String body;

  const MustEnglishCard({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: BayanColors.tertiary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: BayanColors.tertiary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.localization.mustEnglish,
                  style: BayanTypography.labelLarge.copyWith(
                    color: BayanColors.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: BayanTypography.bodyMedium.copyWith(
                    color: BayanColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
