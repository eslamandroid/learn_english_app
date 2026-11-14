import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../core/utils/voice_preferences.dart';
import '../../../../core/widgets/play_my_voice_button.dart';
import '../../../../shared/enums/playback_speed.dart';
import '../../domain/entities/sentence_item.dart';
import '../bloc/sentence_practice/sentence_practice_state.dart';
import 'mic_button.dart';
import 'repeat_result_box.dart';
import 'sentence_topic_illustration.dart';
import 'voice_toggles.dart';

/// Cards-mode card (TASK_sentences_ui_redesign §3.1). Centred stack of
/// illustration → English → Arabic → spacer → pills → mic → hint. If an
/// STT attempt has completed, [RepeatResultBox] appears under the Arabic
/// line and the illustration height drops from 190 → 150.
class SentenceCardLarge extends StatelessWidget {
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

  const SentenceCardLarge({
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
    // While the mic is live we must NOT render the previous attempt's
    // RepeatResultBox — a stale "YOU SAID · 60%" sitting under the sentence
    // the user is now re-trying reads as the current result (TASK 12.2 §B).
    // The listening pattern is handled by `_HintLine` below.
    final showResult = !isListening &&
        attempt?.outcome == SentencePracticeOutcome.assessed &&
        attempt?.assessment != null;
    final illustrationHeight = showResult ? 150.0 : 190.0;

    return Container(
      decoration: BoxDecoration(
        color: BayanColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: BayanColors.onSurface.withValues(alpha: .07),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: illustrationHeight,
                  child: SentenceTopicIllustration(
                    iconKey: topicIconKey,
                    size: illustrationHeight,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  sentence.english,
                  textAlign: TextAlign.center,
                  style: BayanTypography.headlineLarge.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.02 * 30,
                    color: BayanColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                if (sentence.arabic.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    sentence.arabic,
                    textAlign: TextAlign.center,
                    style: BayanTypography.bodyLarge.copyWith(
                      fontSize: 21,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      color: BayanColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
                if (showResult) ...[
                  const SizedBox(height: 14),
                  RepeatResultBox(
                    assessment: attempt!.assessment!,
                    onTryAgain: onTryAgain,
                    recordingPath: attempt!.recordingPath,
                  ),
                ],
                const SizedBox(height: 20),
                VoiceToggles(
                  accent: accent,
                  speed: speed,
                  onAccentChanged: onAccentChanged,
                  onSpeedChanged: onSpeedChanged,
                ),
                const SizedBox(height: 18),
                MicButton(
                  mode: _micMode(showResult),
                  onTap: onMicTap,
                ),
                const SizedBox(height: 10),
                _HintLine(
                  isListening: isListening,
                  armed: armed,
                  partialText: partialText,
                  attempt: attempt,
                ),
              ],
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: _SpeakerButton(isPlaying: isPlaying, onTap: onPlayTap),
          ),
        ],
      ),
    );
  }

  MicButtonMode _micMode(bool showResult) {
    if (isListening) return MicButtonMode.listening;
    if (showResult) return MicButtonMode.outlined;
    return MicButtonMode.idle;
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

class _HintLine extends StatelessWidget {
  final bool isListening;
  final bool armed;
  final String partialText;
  final SentencePracticeAttempt? attempt;

  const _HintLine({
    required this.isListening,
    required this.armed,
    required this.partialText,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color, text) = _resolve();
    // Replay only applies after a non-assessed failure (noSpeech / denied /
    // unavailable with a usable recording). Assessed outcomes already carry
    // the replay button inside the RepeatResultBox above the hint, so
    // showing a second one here would be a duplicate.
    final att = attempt;
    final showReplay = !isListening &&
        att != null &&
        att.outcome != SentencePracticeOutcome.assessed &&
        att.recordingPath != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: BayanTypography.bodySmall.copyWith(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (showReplay) ...[
          const SizedBox(width: 4),
          PlayMyVoiceButton(recordingPath: att.recordingPath),
        ],
      ],
    );
  }

  (IconData, Color, String) _resolve() {
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
        p.isEmpty ? 'Listening… say the sentence' : '"$p"',
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
      SentencePracticeOutcome.assessed => (
          Icons.mic_none_rounded,
          BayanColors.textMuted,
          'Tap the mic and say the sentence.',
        ),
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
    };
  }
}
