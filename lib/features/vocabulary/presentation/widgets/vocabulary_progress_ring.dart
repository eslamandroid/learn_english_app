import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_typography.dart';

/// Small circular progress indicator with a percentage label in the middle —
/// used on the topic grid cards. Progress is `0.0..1.0`.
class VocabularyProgressRing extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;

  const VocabularyProgressRing({
    super.key,
    required this.progress,
    required this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0.0, 1.0) * 100).round();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 3,
              backgroundColor: color.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '$pct%',
            style: BayanTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
