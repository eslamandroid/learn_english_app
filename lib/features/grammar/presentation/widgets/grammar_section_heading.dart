import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

/// Section heading used inside a lesson body — bold label on the left,
/// lightbulb glyph on the right.
class GrammarSectionHeading extends StatelessWidget {
  final String label;
  final IconData trailingIcon;

  const GrammarSectionHeading({
    super.key,
    required this.label,
    this.trailingIcon = Icons.lightbulb_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: BayanTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Icon(
          trailingIcon,
          color: BayanColors.onSurfaceVariant,
          size: 22,
        ),
      ],
    );
  }
}
