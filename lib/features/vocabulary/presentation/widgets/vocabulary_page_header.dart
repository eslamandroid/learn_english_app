import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

/// Section header used across the flat vocabulary screens (topics + subtopics).
///
/// Layout: a circular back button on the left, then a two-line title column —
/// an all-caps [label] on top (accent color, spaced) and the main [title]
/// below. An optional [trailing] slot leaves room for a badge or action.
///
/// Deliberately does not stack a header + footer inside a Column when hosted
/// by a screen — screens keep this widget in Scaffold.body's Column but use
/// Scaffold.appBar/bottomNavigationBar for the actual chrome the OS expects.
class VocabularyPageHeader extends StatelessWidget {
  final String label;
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  const VocabularyPageHeader({
    super.key,
    required this.label,
    required this.title,
    required this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.containerPadding,
        AppConstants.spacingSm,
        AppConstants.containerPadding,
        AppConstants.spacingSm,
      ),
      child: Row(
        children: [
          _HeaderBackButton(onPressed: onBack),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: BayanTypography.labelMedium.copyWith(
                    color: BayanColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BayanTypography.titleLarge.copyWith(
                    color: BayanColors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppConstants.spacingSm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _HeaderBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BayanColors.surfaceContainerLowest.withValues(alpha: .86),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        tooltip: 'Back',
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: BayanColors.onSurface,
        ),
      ),
    );
  }
}
