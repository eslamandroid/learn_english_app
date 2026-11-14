import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../core/utils/voice_preferences.dart';
import '../../../../shared/enums/playback_speed.dart';

/// Segmented US/UK + Slow/Normal pills — "nested" pair laid out side-by-side.
/// Pure stateless; parent owns both selections (held in the practice bloc).
class VoiceToggles extends StatelessWidget {
  final VoiceAccent accent;
  final PlaybackSpeed speed;
  final ValueChanged<VoiceAccent> onAccentChanged;
  final ValueChanged<PlaybackSpeed> onSpeedChanged;
  final MainAxisAlignment alignment;

  const VoiceToggles({
    super.key,
    required this.accent,
    required this.speed,
    required this.onAccentChanged,
    required this.onSpeedChanged,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        _Pill<VoiceAccent>(
          options: const [
            _PillOption(VoiceAccent.us, 'US'),
            _PillOption(VoiceAccent.uk, 'UK'),
          ],
          selected: accent,
          onChanged: onAccentChanged,
        ),
        const SizedBox(width: 8),
        _Pill<PlaybackSpeed>(
          options: [
            for (final s in PlaybackSpeed.values) _PillOption(s, s.label),
          ],
          selected: speed,
          onChanged: onSpeedChanged,
        ),
      ],
    );
  }
}

class _PillOption<T> {
  final T value;
  final String label;
  const _PillOption(this.value, this.label);
}

class _Pill<T> extends StatelessWidget {
  final List<_PillOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  const _Pill({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: BayanColors.tileTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final opt in options)
            GestureDetector(
              onTap: () => onChanged(opt.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: opt.value == selected
                      ? BayanColors.cardBg
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: opt.value == selected
                      ? [
                          BoxShadow(
                            color:
                                BayanColors.onSurface.withValues(alpha: .06),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  opt.label,
                  style: BayanTypography.labelMedium.copyWith(
                    color: opt.value == selected
                        ? BayanColors.primary
                        : BayanColors.textMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
