import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/enums/cefr_level.dart';

/// Horizontal row of chips: "All" + A1..C2. Null selection means "All".
class DictionaryLevelFilter extends StatelessWidget {
  final CefrLevel? selected;
  final ValueChanged<CefrLevel?> onChanged;

  const DictionaryLevelFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: CefrLevel.values.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          if (i == 0) {
            return _Chip(
              label: 'All',
              color: BayanColors.primary,
              selected: selected == null,
              onTap: () => onChanged(null),
            );
          }
          final level = CefrLevel.values[i - 1];
          return _Chip(
            label: level.label,
            color: level.color,
            selected: selected == level,
            onTap: () => onChanged(level),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: BayanTypography.labelMedium.copyWith(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
