import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/bayan_colors.dart';
import '../../core/theme/bayan_typography.dart';

/// Generic error state with a tinted icon badge, title, message, and retry
/// action. Centered, designed to fill the body area of a screen.
class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String title;
  final IconData icon;

  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Something went wrong',
    this.icon = Icons.error_outline_rounded,
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
                color: BayanColors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: BayanColors.error),
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
            const SizedBox(height: AppConstants.spacingMd),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
