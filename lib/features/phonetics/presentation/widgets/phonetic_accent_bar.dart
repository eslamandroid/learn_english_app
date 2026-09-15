import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

class PhoneticAccentBar extends StatelessWidget {
  final String currentAccent;
  final ValueChanged<String> onChanged;

  const PhoneticAccentBar({
    super.key,
    required this.currentAccent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: BayanColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Switch pronunciation accent:',
              style: BayanTypography.bodyMedium.copyWith(
                color: BayanColors.onSurface,
              ),
            ),
          ),
          _AccentSegment(
            options: const ['us', 'uk'],
            labels: const ['US', 'UK'],
            selected: currentAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AccentSegment extends StatelessWidget {
  final List<String> options;
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onChanged;

  const _AccentSegment({
    required this.options,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(options[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMd,
                  vertical: AppConstants.spacingXs + 2,
                ),
                decoration: BoxDecoration(
                  color: selected == options[i]
                      ? BayanColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Text(
                  labels[i],
                  style: BayanTypography.labelLarge.copyWith(
                    color: selected == options[i]
                        ? BayanColors.onPrimary
                        : BayanColors.onSurface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
