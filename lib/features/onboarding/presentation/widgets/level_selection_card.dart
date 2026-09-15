import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/enums/cefr_level.dart';

class LevelSelectionCard extends StatelessWidget {
  final CefrLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const LevelSelectionCard({
    super.key,
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: BoxDecoration(
            color: isSelected
                ? level.color.withValues(alpha: 0.12)
                : BayanColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: isSelected ? level.color : BayanColors.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: level.color,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Text(
                  level.label,
                  style: BayanTypography.labelLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${level.label} — ${level.description}',
                      style: BayanTypography.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _hint(level),
                      style: BayanTypography.bodySmall.copyWith(
                        color: BayanColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: level.color)
              else
                const Icon(
                  Icons.radio_button_unchecked,
                  color: BayanColors.outlineVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _hint(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1:
        return 'I know a few words and phrases';
      case CefrLevel.a2:
        return 'I can have basic conversations';
      case CefrLevel.b1:
        return 'I can discuss familiar topics';
      case CefrLevel.b2:
        return 'I can express ideas clearly';
      case CefrLevel.c1:
        return 'I can use English fluently';
      case CefrLevel.c2:
        return 'I am near-native fluent';
    }
  }
}
