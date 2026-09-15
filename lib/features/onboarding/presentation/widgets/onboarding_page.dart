import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.containerPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              color: BayanColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 72, color: BayanColors.onPrimaryContainer),
          ),
          const SizedBox(height: AppConstants.spacingXl),
          Text(
            title,
            style: BayanTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            description,
            style: BayanTypography.bodyMedium.copyWith(
              color: BayanColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
