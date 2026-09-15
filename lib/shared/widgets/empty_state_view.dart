import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/bayan_colors.dart';
import '../../core/theme/bayan_typography.dart';

/// Generic empty state with a tinted icon badge, title, and message. Centered,
/// designed to fill the body area of a screen.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: BayanColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: BayanColors.primary),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(title, style: BayanTypography.titleLarge),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: BayanTypography.bodyMedium.copyWith(
                color: BayanColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
