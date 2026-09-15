import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/widgets/arabic_visibility.dart';

/// Tinted card with a left accent bar holding an Arabic translation.
/// Collapses entirely when the user has disabled Arabic content in Settings.
class ArabicTranslationBlock extends StatelessWidget {
  final String text;

  const ArabicTranslationBlock({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return ArabicVisibility(child: _block());
  }

  Widget _block() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacingMd,
          AppConstants.spacingMd,
          AppConstants.spacingMd,
          AppConstants.spacingMd,
        ),
        decoration: BoxDecoration(
          color: BayanColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: const Border(
            right: BorderSide(color: BayanColors.primary, width: 3),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: BayanTypography.bodyMedium.copyWith(
            color: BayanColors.onSurface,
            height: 1.7,
          ),
        ),
      ),
    );
  }
}
