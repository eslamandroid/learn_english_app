import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

/// Trailing widget pattern for a settings row that opens a picker — shows
/// the current value text and a small unfold-more chevron.
class ValueWithStepper extends StatelessWidget {
  final String value;

  const ValueWithStepper({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: BayanTypography.bodyMedium.copyWith(
            color: BayanColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(
          Icons.unfold_more_rounded,
          size: 20,
          color: BayanColors.onSurfaceVariant,
        ),
      ],
    );
  }
}
