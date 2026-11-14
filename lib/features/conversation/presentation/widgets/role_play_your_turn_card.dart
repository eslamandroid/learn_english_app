import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/widgets/arabic_visibility.dart';
import '../../domain/entities/conversation_line.dart';

/// Highlighted "YOUR TURN" card used on the Role-play player when the
/// pointer lands on a line belonging to the user's selected character.
///
/// Visual anchor is a dashed primary-coloured border (drawn by a lightweight
/// custom painter; no third-party dashed-border package is added) + a large
/// pulsing green mic (success tint). The pulse is implemented with a tiny
/// looping [TweenAnimationBuilder] — no external animation libs.
class RolePlayYourTurnCard extends StatelessWidget {
  final ConversationLine line;
  final bool isChecking;
  final bool isPreviewPlaying;
  final VoidCallback onPreview;
  final VoidCallback onMicTap;

  const RolePlayYourTurnCard({
    super.key,
    required this.line,
    required this.isChecking,
    required this.isPreviewPlaying,
    required this.onPreview,
    required this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: BayanColors.primary,
        strokeWidth: 1.8,
        dashLength: 7,
        gapLength: 5,
        radius: 20,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: BayanColors.primaryTint.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: BayanColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'YOUR TURN',
                    style: BayanTypography.labelMedium.copyWith(
                      fontSize: 10.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.08 * 10.5,
                    ),
                  ),
                ),
                const Spacer(),
                _PreviewButton(
                  isPlaying: isPreviewPlaying,
                  onTap: onPreview,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              line.english,
              style: BayanTypography.headlineLarge.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: BayanColors.onSurface,
                height: 1.25,
              ),
            ),
            if (line.arabic.isNotEmpty)
              ArabicVisibility(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    line.arabic,
                    style: BayanTypography.bodyMedium.copyWith(
                      fontFamily: BayanTypography.arabicFontFamily,
                      fontWeight: FontWeight.w600,
                      color: BayanColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Center(child: _PulsingMic(active: isChecking, onTap: onMicTap)),
            const SizedBox(height: 10),
            Center(
              child: Text(
                isChecking
                    ? 'Listening… say your line'
                    : 'Tap and say your line',
                style: BayanTypography.bodySmall.copyWith(
                  color: BayanColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const _PreviewButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: BayanColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      icon: Icon(
        isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
        size: 16,
      ),
      label: Text(
        isPlaying ? 'Stop' : 'Hear it first',
        style: BayanTypography.labelMedium.copyWith(
          color: BayanColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _PulsingMic extends StatefulWidget {
  final bool active;
  final VoidCallback onTap;
  const _PulsingMic({required this.active, required this.onTap});

  @override
  State<_PulsingMic> createState() => _PulsingMicState();
}

class _PulsingMicState extends State<_PulsingMic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double size = 64;
    final color = widget.active ? BayanColors.error : BayanColors.successStrong;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: SizedBox(
        width: size + 24,
        height: size + 24,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (ctx, _) {
            final t = _ctrl.value; // 0..1
            final ringScale = 1 + 0.35 * t;
            final ringAlpha = (1 - t) * 0.5;
            return Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing ring
                Container(
                  width: size * ringScale,
                  height: size * ringScale,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: ringAlpha * 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                // Solid mic
                Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.30),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.active ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: size * 0.44,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Lightweight dashed-border painter — avoids an extra package.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    for (final m in metrics) {
      var distance = 0.0;
      while (distance < m.length) {
        final next = (distance + dashLength).clamp(0, m.length).toDouble();
        canvas.drawPath(m.extractPath(distance, next), paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength ||
      old.radius != radius;
}
