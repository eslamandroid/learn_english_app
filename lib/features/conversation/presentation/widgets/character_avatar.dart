import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

/// Deterministic circular avatar: first letter of the character name on a
/// color seeded by a hash of the full name — so "Lisa" is always the same
/// hue across every screen in the app, not shuffled per build (TASK 10 §6).
class CharacterAvatar extends StatelessWidget {
  final String name;
  final double size;
  final double? borderWidth;
  final Color? borderColor;

  const CharacterAvatar({
    super.key,
    required this.name,
    this.size = 36,
    this.borderWidth,
    this.borderColor,
  });

  // A short, high-contrast palette. Deterministic index via name.hashCode so
  // the same character always maps to the same color.
  static const List<Color> _palette = [
    Color(0xFF4F8CFF), // blue
    Color(0xFFF2A33A), // amber
    Color(0xFF2BB673), // green
    Color(0xFFD946B6), // pink
    Color(0xFF8B5CF6), // violet
    Color(0xFFEF4444), // red
    Color(0xFF0EA5E9), // sky
    Color(0xFF14B8A6), // teal
  ];

  static Color colorFor(String name) {
    if (name.isEmpty) return _palette.first;
    final idx = name.hashCode.abs() % _palette.length;
    return _palette[idx];
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(name);
    final letter = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: borderWidth != null && borderWidth! > 0
            ? Border.all(
                color: borderColor ?? BayanColors.surfaceContainerLowest,
                width: borderWidth!,
              )
            : null,
      ),
      child: Text(
        letter,
        style: BayanTypography.labelLarge.copyWith(
          fontSize: size * 0.42,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
