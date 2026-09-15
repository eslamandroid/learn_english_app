import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

class AccentToggle extends StatelessWidget {
  final String currentAccent;
  final ValueChanged<String> onChanged;

  const AccentToggle({
    super.key,
    required this.currentAccent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.containerPadding,
        vertical: AppConstants.spacingSm,
      ),
      padding: const EdgeInsets.all(AppConstants.spacingXs),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        children: [
          _AccentChip(
            label: 'US',
            value: 'us',
            isSelected: currentAccent == 'us',
            onTap: () => onChanged('us'),
          ),
          _AccentChip(
            label: 'UK',
            value: 'uk',
            isSelected: currentAccent == 'uk',
            onTap: () => onChanged('uk'),
          ),
        ],
      ),
    );
  }
}

class _AccentChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccentChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? BayanColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
          child: Text(
            label,
            style: BayanTypography.labelLarge.copyWith(
              color: isSelected ? BayanColors.onPrimary : BayanColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
