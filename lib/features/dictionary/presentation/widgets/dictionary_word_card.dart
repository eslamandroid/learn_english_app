import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../features/phonetics/domain/entities/pronunciation_outcome.dart';
import '../../../../features/phonetics/presentation/bloc/pronunciation/pronunciation_bloc.dart';
import '../../../../features/phonetics/presentation/bloc/pronunciation/pronunciation_event.dart';
import '../../../../features/phonetics/presentation/bloc/pronunciation/pronunciation_state.dart';
import '../../../../shared/widgets/arabic_visibility.dart';
import '../../domain/entities/dictionary_word.dart';

/// Raised dictionary card. Layout matches TASK_08 §3 strictly:
///
/// • The left group (level chip + the word itself) lives in an `Expanded(Wrap)`.
///   Long words (e.g. "lie (verb - to not tell the truth)" — the actual
///   longest word_list entry at 34 chars) wrap under the chip instead of
///   either (a) pushing the trailing buttons off-screen or (b) being clipped
///   with an ellipsis (unacceptable for a dictionary).
/// • The trailing three buttons live in a sibling `Row(mainAxisSize: min)` —
///   never inside the same Wrap, since they must stay a fixed, intact group.
/// • Second row (IPA + Arabic) uses the same Wrap pattern defensively.
/// • The star button writes to `my_word_list` optimistically; the mic button
///   reuses [PronunciationBloc] from phonetics without modification (§5).
class DictionaryWordCard extends StatelessWidget {
  final DictionaryWord word;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onToggleSaved;

  const DictionaryWordCard({
    super.key,
    required this.word,
    required this.isPlaying,
    required this.onPlay,
    required this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PronunciationBloc, PronunciationState>(
      buildWhen: (p, c) =>
          p.activeExampleId != c.activeExampleId ||
          p.attempts[word.id] != c.attempts[word.id] ||
          (p.activeExampleId == word.id && p.armed != c.armed),
      builder: (ctx, p) {
        final isListening = p.activeExampleId == word.id;
        final attempt = p.attempts[word.id];
        return Container(
          decoration: BoxDecoration(
            color: BayanColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            boxShadow: [
              BoxShadow(
                color: BayanColors.onSurface.withValues(alpha: 0.07),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TitleRow(
                word: word,
                isPlaying: isPlaying,
                isListening: isListening,
                onPlay: onPlay,
                onToggleSaved: onToggleSaved,
                onMic: () => _toggleMic(ctx, isListening),
              ),
              if (word.pronunciation.isNotEmpty || word.arabic.isNotEmpty)
                const SizedBox(height: 6),
              _PronunciationAndArabic(
                pronunciation: word.pronunciation,
                arabic: word.arabic,
              ),
              if (word.example.isNotEmpty) ...[
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: BayanColors.outlineVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 10),
                _ExampleRow(text: word.example),
              ],
              if (attempt != null || (isListening && p.armed)) ...[
                const SizedBox(height: 10),
                _FeedbackLine(
                  isListening: isListening,
                  armed: p.armed,
                  partialText: p.partialText,
                  attempt: attempt,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _toggleMic(BuildContext context, bool isListening) {
    final bloc = context.read<PronunciationBloc>();
    if (isListening) {
      bloc.add(const StopPronunciationCheck());
    } else {
      bloc.add(StartPronunciationCheck(
        exampleId: word.id,
        targetWord: word.word,
      ));
    }
  }
}

// ─── Title row ───────────────────────────────────────────────────────────────

class _TitleRow extends StatelessWidget {
  final DictionaryWord word;
  final bool isPlaying;
  final bool isListening;
  final VoidCallback onPlay;
  final VoidCallback onMic;
  final VoidCallback onToggleSaved;

  const _TitleRow({
    required this.word,
    required this.isPlaying,
    required this.isListening,
    required this.onPlay,
    required this.onMic,
    required this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _LevelChip(level: word.level.label, color: word.level.color),
              Text(
                word.word,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: BayanTypography.headlineLarge.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: BayanColors.onSurface,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CircleIconButton(
              icon:
                  isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
              tooltip: isPlaying ? 'Stop' : 'Play audio',
              bg: BayanColors.primary.withValues(alpha: 0.10),
              fg: BayanColors.primary,
              filledBg: BayanColors.primary,
              filledFg: Colors.white,
              filled: isPlaying,
              onTap: onPlay,
            ),
            const SizedBox(width: 7),
            _CircleIconButton(
              icon: isListening ? Icons.stop_rounded : Icons.mic_rounded,
              tooltip: isListening ? 'Stop listening' : 'Practice saying it',
              bg: BayanColors.success,
              fg: Colors.white,
              filledBg: BayanColors.error,
              filledFg: Colors.white,
              filled: isListening,
              elevated: true,
              onTap: onMic,
            ),
            const SizedBox(width: 7),
            _CircleIconButton(
              icon: word.isSaved
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              tooltip:
                  word.isSaved ? 'Remove from My Words' : 'Save to My Words',
              bg: BayanColors.warning.withValues(alpha: 0.14),
              fg: BayanColors.warning,
              filledBg: BayanColors.warning,
              filledFg: Colors.white,
              filled: word.isSaved,
              elevated: word.isSaved,
              onTap: onToggleSaved,
            ),
          ],
        ),
      ],
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String level;
  final Color color;
  const _LevelChip({required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        level,
        style: BayanTypography.labelMedium.copyWith(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─── Pronunciation + Arabic row (also Wrap-based) ────────────────────────────

class _PronunciationAndArabic extends StatelessWidget {
  final String pronunciation;
  final String arabic;
  const _PronunciationAndArabic({
    required this.pronunciation,
    required this.arabic,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (pronunciation.isNotEmpty) {
      children.add(Text(
        pronunciation,
        style: BayanTypography.bodySmall.copyWith(
          color: BayanColors.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ));
    }
    if (arabic.isNotEmpty) {
      children.add(ArabicVisibility(
        child: Text(
          arabic,
          style: BayanTypography.bodyMedium.copyWith(
            fontFamily: BayanTypography.arabicFontFamily,
            fontWeight: FontWeight.w700,
            color: BayanColors.onSurfaceVariant,
          ),
        ),
      ));
    }
    if (children.isEmpty) return const SizedBox.shrink();
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: children,
    );
  }
}

// ─── Example row (quoted) ────────────────────────────────────────────────────

class _ExampleRow extends StatelessWidget {
  final String text;
  const _ExampleRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.format_quote_rounded,
            size: 14,
            color: BayanColors.outlineVariant.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: BayanTypography.bodySmall.copyWith(
              color: BayanColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Feedback line (binary correct / incorrect for a single word) ───────────

class _FeedbackLine extends StatelessWidget {
  final bool isListening;
  final bool armed;
  final String partialText;
  final PronunciationAttempt? attempt;

  const _FeedbackLine({
    required this.isListening,
    required this.armed,
    required this.partialText,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    if (isListening) {
      final text = armed
          ? (partialText.trim().isEmpty
              ? 'Listening… say the word'
              : '"${partialText.trim()}"')
          : 'Getting ready…';
      return _Pill(
        icon: Icons.graphic_eq_rounded,
        color: BayanColors.primary,
        text: text,
      );
    }
    final att = attempt;
    if (att == null) return const SizedBox.shrink();
    return switch (att.outcome) {
      PronunciationOutcome.correct => _Pill(
          icon: Icons.check_circle_rounded,
          color: BayanColors.success,
          text: 'Correct — "${att.heard}"',
        ),
      PronunciationOutcome.incorrect => _Pill(
          icon: Icons.refresh_rounded,
          color: BayanColors.error,
          text: att.heard.isEmpty
              ? 'Try again'
              : 'Heard "${att.heard}" — try again',
        ),
      PronunciationOutcome.noSpeech => _Pill(
          icon: Icons.hearing_disabled_rounded,
          color: BayanColors.warning,
          text: "Didn't catch that — try again.",
        ),
      PronunciationOutcome.denied => _Pill(
          icon: Icons.mic_off_rounded,
          color: BayanColors.error,
          text: 'Microphone permission is needed.',
        ),
      PronunciationOutcome.unavailable => _Pill(
          icon: Icons.error_outline_rounded,
          color: BayanColors.error,
          text: 'Speech recognition is unavailable.',
        ),
    };
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _Pill({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: BayanTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Circle icon button — the only building block for the three trailing btns ─

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color bg;
  final Color fg;
  final Color filledBg;
  final Color filledFg;
  final bool filled;

  /// When true, drop a tinted shadow — used for the mic (always) and the
  /// star when saved, to signal they're the "active, important" affordances.
  final bool elevated;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.bg,
    required this.fg,
    required this.filledBg,
    required this.filledFg,
    required this.filled,
    required this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = filled ? filledBg : bg;
    final effectiveFg = filled ? filledFg : fg;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: effectiveBg,
              shape: BoxShape.circle,
              boxShadow: elevated
                  ? [
                      BoxShadow(
                        color: effectiveBg.withValues(alpha: 0.30),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, size: 18, color: effectiveFg),
          ),
        ),
      ),
    );
  }
}
