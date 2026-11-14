import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';

/// Prev/next 44-circle buttons with a dot indicator between them. Lives below
/// the big sentence card in Cards mode.
class PagerControls extends StatelessWidget {
  final int count;
  final int current;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const PagerControls({
    super.key,
    required this.count,
    required this.current,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: onPrev,
            tooltip: 'Previous sentence',
          ),
          Expanded(child: _DotIndicator(count: count, current: current)),
          _CircleButton(
            icon: Icons.arrow_forward_rounded,
            onTap: onNext,
            tooltip: 'Next sentence',
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BayanColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: enabled
                  ? BayanColors.primary
                  : BayanColors.primary.withValues(alpha: .35),
            ),
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;
  const _DotIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    // Cap visible dots to avoid overflow on long lessons.
    final visible = count > 7 ? 7 : count;
    final start = (current - 3).clamp(0, (count - visible).clamp(0, count));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(visible, (i) {
        final idx = start + i;
        final active = idx == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? BayanColors.primary : BayanColors.dotInactive,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
