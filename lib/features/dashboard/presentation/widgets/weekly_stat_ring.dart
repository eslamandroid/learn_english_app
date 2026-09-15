import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

class WeeklyStatRing extends StatelessWidget {
  final String value;
  final String label;
  final double progress; // 0.0 .. 1.0
  final Color color;

  const WeeklyStatRing({
    super.key,
    required this.value,
    required this.label,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 76,
          height: 76,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(76, 76),
                painter: _RingPainter(
                  progress: progress.clamp(0.0, 1.0),
                  color: color,
                ),
              ),
              Text(
                value,
                style: BayanTypography.titleLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: BayanTypography.bodySmall.copyWith(
            color: BayanColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = BayanColors.surfaceContainerHigh;
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      progress * 2 * pi,
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
