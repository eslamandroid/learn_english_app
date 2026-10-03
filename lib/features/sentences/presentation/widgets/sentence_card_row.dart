import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../core/utils/voice_preferences.dart';
import '../../../../shared/enums/playback_speed.dart';
import '../../domain/entities/sentence_item.dart';
import '../bloc/sentence_practice/sentence_practice_state.dart';
import 'mic_button.dart';
import 'repeat_result_box.dart';
import 'sentence_topic_illustration.dart';
import 'voice_toggles.dart';

/// List-mode card (TASK_sentences_ui_redesign §3.2). Compact row: 56×56
/// illustration tile · EN + AR · speaker · hairline · pills + mic · hint.
class SentenceCardRow extends StatelessWidget {
  final SentenceItem sentence;
  final String? topicIconKey;
  final bool isPlaying;
  final VoidCallback onPlayTap;
  final VoiceAccent accent;
  final PlaybackSpeed speed;
  final ValueChanged<VoiceAccent> onAccentChanged;
  final ValueChanged<PlaybackSpeed> onSpeedChanged;
  final bool isListening;
  final bool armed;
  final String partialText;
  final SentencePracticeAttempt? attempt;
  final VoidCallback onMicTap;
  final VoidCallback onTryAgain;

  const SentenceCardRow({
    super.key,
    required this.sentence,
    required this.topicIconKey,
    required this.isPlaying,
    required this.onPlayTap,
    required this.accent,
    required this.speed,
    required this.onAccentChanged,
    required this.onSpeedChanged,
    required this.isListening,
    required this.armed,
    required this.partialText,
    required this.attempt,
    required this.onMicTap,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final showResult =
        attempt?.outcome == SentencePracticeOutcome.assessed &&
            attempt?.assessment != null;

    return Container(
      decoration: BoxDecoration(
        color: BayanColors.cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: BayanColors.onSurface.withValues(alpha: .06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: BayanColors.tileTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: SentenceTopicIllustration(
                  iconKey: topicIconKey,
                  size: 50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sentence.english,
                      style: BayanTypography.titleLarge.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: BayanColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (sentence.arabic.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        sentence.arabic,
                        style: BayanTypography.bodyMedium.copyWith(
                          fontSize: 16,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                          color: BayanColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _SpeakerButton(isPlaying: isPlaying, onTap: onPlayTap),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
              height: 1,
              color: BayanColors.divider,
              thickness: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: VoiceToggles(
                    accent: accent,
                    speed: speed,
                    onAccentChanged: onAccentChanged,
                    onSpeedChanged: onSpeedChanged,
                    alignment: MainAxisAlignment.start,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MicButton(
                mode: _micMode(showResult),
                onTap: onMicTap,
                size: 48,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (showResult)
            RepeatResultBox(
              assessment: attempt!.assessment!,
              onTryAgain: onTryAgain,
            )
          else
            _hintLine(),
        ],
      ),
    );
  }

  MicButtonMode _micMode(bool showResult) {
    if (isListening) return MicButtonMode.listening;
    if (showResult) return MicButtonMode.outlined;
    return MicButtonMode.idle;
  }

  Widget _hintLine() {
    final (icon, color, text) = _resolveHint();
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: BayanTypography.bodySmall.copyWith(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  (IconData, Color, String) _resolveHint() {
    if (isListening) {
      if (!armed) {
        return (
          Icons.graphic_eq_rounded,
          BayanColors.primary,
          'Getting ready…',
        );
      }
      final p = partialText.trim();
      return (
        Icons.graphic_eq_rounded,
        BayanColors.primary,
        p.isEmpty ? 'Listening…' : '"$p"',
      );
    }
    final att = attempt;
    if (att == null) {
      return (
        Icons.mic_none_rounded,
        BayanColors.textMuted,
        'Tap the mic and say the sentence.',
      );
    }
    return switch (att.outcome) {
      SentencePracticeOutcome.noSpeech => (
          Icons.hearing_disabled_rounded,
          BayanColors.warnFg,
          "Didn't catch that — try again.",
        ),
      SentencePracticeOutcome.permissionDenied => (
          Icons.mic_off_rounded,
          BayanColors.error,
          'Microphone permission is needed to practice.',
        ),
      SentencePracticeOutcome.unavailable => (
          Icons.error_outline_rounded,
          BayanColors.error,
          'Speech recognition is unavailable on this device.',
        ),
      SentencePracticeOutcome.assessed => (
          Icons.mic_none_rounded,
          BayanColors.textMuted,
          'Tap the mic and say the sentence.',
        ),
    };
  }
}

class _SpeakerButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const _SpeakerButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isPlaying ? 'Stop audio' : 'Play audio',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isPlaying ? BayanColors.primary : BayanColors.primaryTint,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
            size: 22,
            color: isPlaying ? Colors.white : BayanColors.primary,
          ),
        ),
      ),
    );
  }
}
