import 'dart:math';

import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/enums/cefr_level.dart';

class GrammarOverviewCard extends StatelessWidget {
  final CefrLevel level;
  final int currentIndex; // 1-based "module N of M"
  final int totalCount;
  final double progress; // 0.0 .. 1.0

  const GrammarOverviewCard({
    super.key,
    required this.level,
    required this.currentIndex,
    required this.totalCount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.localization.grammar,
                      style: BayanTypography.headlineLarge,
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    Row(
                      children: [
                        _LevelPill(level: level),
                        const SizedBox(width: AppConstants.spacingSm),
                        Text(
                          totalCount == 0
                              ? context.localization.noModulesYet
                              : context.localization
                                  .moduleNOfM(currentIndex, totalCount),
                          style: BayanTypography.bodyMedium.copyWith(
                            color: BayanColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              _ProgressRing(progress: progress),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: BayanColors.surfaceContainerHigh,
              valueColor:
                  const AlwaysStoppedAnimation(BayanColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  final CefrLevel level;
  const _LevelPill({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: BayanColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        '${level.label} ${level.description}',
        style: BayanTypography.labelMedium.copyWith(
          color: BayanColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  const _ProgressRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0.0, 1.0) * 100).round();
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(64, 64),
            painter: _RingPainter(progress: progress.clamp(0.0, 1.0)),
          ),
          Text(
            '$pct%',
            style: BayanTypography.labelLarge.copyWith(
              color: BayanColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

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
      ..color = BayanColors.primary;

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
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
