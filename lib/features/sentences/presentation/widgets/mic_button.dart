import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';

/// Three visual states (per TASK_sentences_ui_redesign §3.1):
///   • idle    — green filled circle with success glow
///   • listening — same green, but a stop icon
///   • outlined  — white bg + green border; used while the YOU SAID result
///                 box is visible, to de-emphasise the mic after an attempt.
enum MicButtonMode { idle, listening, outlined }

class MicButton extends StatelessWidget {
  final MicButtonMode mode;
  final double size;
  final VoidCallback onTap;

  const MicButton({
    super.key,
    required this.mode,
    required this.onTap,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final isOutlined = mode == MicButtonMode.outlined;
    final isListening = mode == MicButtonMode.listening;

    return Semantics(
      button: true,
      label: isListening ? 'Stop listening' : 'Tap to speak',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isOutlined ? BayanColors.cardBg : BayanColors.successStrong,
            shape: BoxShape.circle,
            border: isOutlined
                ? Border.all(color: BayanColors.successStrong, width: 2)
                : null,
            boxShadow: isOutlined
                ? null
                : [
                    BoxShadow(
                      color:
                          BayanColors.successStrong.withValues(alpha: .16),
                      blurRadius: 0,
                      spreadRadius: 8,
                    ),
                  ],
          ),
          child: Icon(
            isListening ? Icons.stop_rounded : Icons.mic_rounded,
            color: isOutlined ? BayanColors.successStrong : Colors.white,
            size: size * 0.46,
          ),
        ),
      ),
    );
  }
}
