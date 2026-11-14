import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import 'character_avatar.dart';

/// Big tap-able character card used on the role-play select screen.
/// Shows an avatar, the character name, a line count, and a selection pill.
class RolePlayCharacterCard extends StatelessWidget {
  final String name;
  final int lineCount;
  final bool isSelected;
  final VoidCallback onTap;

  const RolePlayCharacterCard({
    super.key,
    required this.name,
    required this.lineCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        isSelected ? BayanColors.primary : BayanColors.outlineVariant;
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Play as $name, $lineCount lines to say',
      child: Material(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: BayanColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? BayanColors.primary : accent,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: BayanColors.onSurface.withValues(
                    alpha: isSelected ? 0.09 : 0.05,
                  ),
                  blurRadius: isSelected ? 20 : 12,
                  offset: Offset(0, isSelected ? 6 : 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                CharacterAvatar(name: name, size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: BayanTypography.titleLarge.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: BayanColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$lineCount lines to say',
                        style: BayanTypography.bodySmall.copyWith(
                          color: BayanColors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _SelectionPip(selected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionPip extends StatelessWidget {
  final bool selected;
  const _SelectionPip({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? BayanColors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? BayanColors.primary : BayanColors.outlineVariant,
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }
}
