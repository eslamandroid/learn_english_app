import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../core/widgets/play_my_voice_button.dart';
import '../../../../shared/widgets/arabic_visibility.dart';
import '../../../sentences/presentation/bloc/sentence_practice/sentence_practice_state.dart';
import '../../domain/entities/conversation_line.dart';
import 'character_avatar.dart';

/// Three visual states (TASK 10 §6):
///   • normal — white bubble
///   • current (while auto-playing) — primary bg, white text, elevated,
///     bigger action buttons + "Now playing" tag
///   • upcoming — normal bubble at .5 opacity
///
/// Alignment switches left/right based on [alignRight] (resolved by the
/// screen from the character's first-appearance order).
class ConversationBubble extends StatelessWidget {
  final ConversationLine line;
  final bool alignRight;

  /// Playback state for this line, computed by the parent from the
  /// ConversationPlayerState.
  final bool isCurrent;
  final bool isUpcoming;
  final bool isPlaying;

  /// Pronunciation attempt from the shared SentencePracticeBloc (keyed by
  /// line.id). Null when no attempt yet. We deliberately *hide* this while
  /// [isListening] is true — a stale "Didn't catch that" sitting under the
  /// mic-live bubble reads as the current result (TASK 12.2 §B).
  final SentencePracticeAttempt? attempt;
  final bool isListening;

  /// Cumulative partial transcript while [isListening] (passed through from
  /// the SentencePracticeBloc). Empty before the engine has recognized
  /// anything; the listening strip shows "Listening…" in that case.
  final String partialText;

  /// True once the mic is confirmed armed. Before this the strip reads
  /// "Get ready…" so the user doesn't speak into a mic that isn't live yet
  /// (same pattern as phonetic_example_table / dictionary_word_card).
  final bool armed;

  final VoidCallback onPlay;
  final VoidCallback onMic;

  const ConversationBubble({
    super.key,
    required this.line,
    required this.alignRight,
    required this.isCurrent,
    required this.isUpcoming,
    required this.isPlaying,
    required this.attempt,
    required this.isListening,
    this.partialText = '',
    this.armed = false,
    required this.onPlay,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Cap matches the design (max-width: 84%). Short lines then size to their
    // intrinsic content; long lines wrap inside this cap instead of
    // stretching across the whole viewport.
    final maxBubbleWidth = screenWidth * 0.84;

    final avatar = CharacterAvatar(name: line.character, size: 32);
    // Flexible — not Expanded — so the bubble shrinks to intrinsic width for
    // short text ("Hi.") instead of expanding to fill the Row's cross-axis
    // bound. The parent ConstrainedBox already imposes the upper limit.
    final bubble = Flexible(child: _bubbleContent(context));

    return Opacity(
      opacity: isUpcoming ? 0.5 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Align(
          // Align is what pins the whole avatar+bubble group to the correct
          // side of the ListView tile — Row's own mainAxisAlignment would
          // only shift inside a Row that already fills the width.
          alignment:
              alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Row(
              // Explicit children ordering is safer than relying on
              // `textDirection: rtl` here — RTL would also flip English text
              // alignment inside the bubble content when ambient
              // Directionality is LTR.
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: alignRight
                  ? [bubble, const SizedBox(width: 8), avatar]
                  : [avatar, const SizedBox(width: 8), bubble],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bubbleContent(BuildContext context) {
    final bg = isCurrent
        ? BayanColors.primary
        : BayanColors.surfaceContainerLowest;
    final textColor = isCurrent ? Colors.white : BayanColors.onSurface;
    final subTextColor = isCurrent
        ? Colors.white.withValues(alpha: 0.9)
        : BayanColors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: BayanColors.onSurface.withValues(
              alpha: isCurrent ? 0.14 : 0.05,
            ),
            blurRadius: isCurrent ? 18 : 10,
            offset: Offset(0, isCurrent ? 8 : 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: alignRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                line.character,
                style: BayanTypography.labelMedium.copyWith(
                  fontSize: 11,
                  color: isCurrent
                      ? Colors.white.withValues(alpha: 0.85)
                      : BayanColors.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Now playing',
                    style: BayanTypography.labelMedium.copyWith(
                      fontSize: 9.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            line.english,
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
            style: BayanTypography.titleLarge.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          if (line.phonetic.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                line.phonetic,
                textAlign: alignRight ? TextAlign.right : TextAlign.left,
                style: BayanTypography.bodySmall.copyWith(
                  color: subTextColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (line.arabic.isNotEmpty)
            ArabicVisibility(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  line.arabic,
                  textAlign: alignRight ? TextAlign.right : TextAlign.left,
                  style: BayanTypography.bodyMedium.copyWith(
                    fontFamily: BayanTypography.arabicFontFamily,
                    fontWeight: FontWeight.w600,
                    color: subTextColor,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          _ActionsRow(
            size: isCurrent ? 34 : 30,
            isCurrent: isCurrent,
            isPlaying: isPlaying,
            isListening: isListening,
            onPlay: onPlay,
            onMic: onMic,
          ),
          // Suppress any stale attempt while the mic is live; otherwise the
          // previous "Didn't catch that" sits under a bubble the user is
          // actively re-recording (TASK 12.2 §B). The listening strip takes
          // its place and shows the live partial transcript.
          if (isListening) ...[
            const SizedBox(height: 6),
            _ListeningStrip(
              armed: armed,
              partialText: partialText,
              isCurrent: isCurrent,
            ),
          ] else if (attempt != null) ...[
            const SizedBox(height: 6),
            _AttemptLine(attempt: attempt!, isCurrent: isCurrent),
          ],
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final double size;
  final bool isCurrent;
  final bool isPlaying;
  final bool isListening;
  final VoidCallback onPlay;
  final VoidCallback onMic;

  const _ActionsRow({
    required this.size,
    required this.isCurrent,
    required this.isPlaying,
    required this.isListening,
    required this.onPlay,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleButton(
          size: size,
          tooltip: isPlaying ? 'Stop' : 'Play line',
          icon: isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
          bg: isCurrent
              ? Colors.white.withValues(alpha: 0.18)
              : BayanColors.primaryTint,
          fg: isCurrent ? Colors.white : BayanColors.primary,
          onTap: onPlay,
        ),
        const SizedBox(width: 6),
        _CircleButton(
          size: size,
          tooltip: isListening ? 'Stop listening' : 'Practice this line',
          icon: isListening ? Icons.stop_rounded : Icons.mic_rounded,
          bg: isListening ? BayanColors.error : BayanColors.successStrong,
          fg: Colors.white,
          elevated: true,
          onTap: onMic,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final double size;
  final String tooltip;
  final IconData icon;
  final Color bg;
  final Color fg;
  final bool elevated;
  final VoidCallback onTap;

  const _CircleButton({
    required this.size,
    required this.tooltip,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: elevated
                  ? [
                      BoxShadow(
                        color: bg.withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, size: size * 0.46, color: fg),
          ),
        ),
      ),
    );
  }
}

/// While the mic is live for this bubble, replaces the stale attempt line
/// with a tiny "Get ready…" (pre-armed) or "Listening… / partial" strip.
/// Mirrors the pattern already in `phonetic_example_table._Feedback`.
class _ListeningStrip extends StatelessWidget {
  final bool armed;
  final String partialText;
  final bool isCurrent;
  const _ListeningStrip({
    required this.armed,
    required this.partialText,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final partial = partialText.trim();
    final text = !armed
        ? 'Get ready…'
        : (partial.isEmpty ? 'Listening…' : '"$partial"');
    final fg = isCurrent ? Colors.white : BayanColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.graphic_eq_rounded, size: 14, color: fg),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: BayanTypography.bodySmall.copyWith(
              color: fg,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _AttemptLine extends StatelessWidget {
  final SentencePracticeAttempt attempt;
  final bool isCurrent;
  const _AttemptLine({required this.attempt, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final a = attempt.assessment;
    if (a == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              attempt.heard.isEmpty
                  ? "Didn't catch that — try again."
                  : 'Heard: "${attempt.heard}"',
              style: BayanTypography.bodySmall.copyWith(
                color: isCurrent
                    ? Colors.white.withValues(alpha: 0.85)
                    : BayanColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          if (attempt.recordingPath != null) ...[
            const SizedBox(width: 4),
            PlayMyVoiceButton(recordingPath: attempt.recordingPath),
          ],
        ],
      );
    }
    final pct = (a.score * 100).round();
    final passed = a.passed;
    final chipBg = passed
        ? BayanColors.successTint
        : BayanColors.warnTint;
    final chipFg = passed ? BayanColors.successFg : BayanColors.warnFg;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.refresh_rounded,
            size: 13,
            color: chipFg,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: BayanTypography.bodySmall.copyWith(
                  color: chipFg,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  for (var i = 0; i < a.words.length; i++) ...[
                    if (i > 0) const TextSpan(text: ' '),
                    TextSpan(
                      text: a.words[i].word,
                      style: TextStyle(
                        color: a.words[i].isCorrect
                            ? BayanColors.successFg
                            : BayanColors.error,
                      ),
                    ),
                  ],
                  TextSpan(text: '  $pct%'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (attempt.recordingPath == null) return chip;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(child: chip),
        const SizedBox(width: 4),
        PlayMyVoiceButton(recordingPath: attempt.recordingPath),
      ],
    );
  }
}
