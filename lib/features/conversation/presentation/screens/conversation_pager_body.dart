import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../features/sentences/presentation/bloc/sentence_practice/sentence_practice_bloc.dart';
import '../../../../features/sentences/presentation/bloc/sentence_practice/sentence_practice_event.dart';
import '../../../../features/sentences/presentation/bloc/sentence_practice/sentence_practice_state.dart';
import '../../../../shared/enums/playback_speed.dart';
import '../../../../shared/widgets/arabic_visibility.dart';
import '../../domain/entities/conversation_line.dart';
import '../bloc/conversation_player/conversation_player_bloc.dart';
import '../bloc/conversation_player/conversation_player_event.dart';
import '../bloc/conversation_player/conversation_player_state.dart';
import '../widgets/character_avatar.dart';

/// Pager view — one line per page, manual swipe only. Swiping stops any
/// in-flight audio/mic and does NOT auto-play the next page (TASK 10 §7).
class ConversationPagerBody extends StatefulWidget {
  final int lessonId;
  const ConversationPagerBody({super.key, required this.lessonId});

  @override
  State<ConversationPagerBody> createState() => _ConversationPagerBodyState();
}

class _ConversationPagerBodyState extends State<ConversationPagerBody> {
  late final PageController _ctrl = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    // Mirror Sentences pager behaviour — stop any in-flight STT and audio
    // on page swipe so switching lines doesn't carry hearing state over.
    context.read<SentencePracticeBloc>().add(const StopSentenceCheck());
    context
        .read<ConversationPlayerBloc>()
        .add(const PauseConversationSequence());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationPlayerBloc, ConversationPlayerState>(
      builder: (ctx, state) {
        if (state.lines.isEmpty) return const SizedBox.shrink();
        final playerBloc = ctx.read<ConversationPlayerBloc>();
        final practiceBloc = ctx.read<SentencePracticeBloc>();

        return Column(
          children: [
            Expanded(
              child: BlocBuilder<SentencePracticeBloc, SentencePracticeState>(
                builder: (ctx, practice) {
                  return PageView.builder(
                    controller: _ctrl,
                    itemCount: state.lines.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (c, i) {
                      final line = state.lines[i];
                      final isListeningThis =
                          practice.activeSentenceId == line.id;
                      final attempt = practice.attempts[line.id];
                      return _PagerCard(
                        line: line,
                        speed: state.speed,
                        isPlaying: state.playingLineId == line.id,
                        isListening: isListeningThis,
                        attempt: attempt,
                        // Scope partialText/armed to the active page only so
                        // a swipe to a different line doesn't carry the
                        // previous mic transcript into view.
                        partialText:
                            isListeningThis ? practice.partialText : '',
                        armed: isListeningThis && practice.armed,
                        onSpeedChanged: (s) =>
                            playerBloc.add(SetConversationSpeed(s)),
                        onPlay: () =>
                            playerBloc.add(PlayConversationSingle(line.id)),
                        onMic: isListeningThis
                            ? () => practiceBloc
                                .add(const StopSentenceCheck())
                            : () => practiceBloc.add(StartSentenceCheck(
                                  sentenceId: line.id,
                                  targetSentence: line.english,
                                )),
                      );
                    },
                  );
                },
              ),
            ),
            _DotIndicator(
              count: state.lines.length,
              current: _currentPage,
            ),
            _MarkCompleteBar(
              isCompleted: state.isCompleted,
              onTap: state.isCompleted
                  ? null
                  : () => playerBloc
                      .add(MarkConversationComplete(lessonId: widget.lessonId)),
            ),
          ],
        );
      },
    );
  }
}

class _PagerCard extends StatelessWidget {
  final ConversationLine line;
  final PlaybackSpeed speed;
  final bool isPlaying;
  final bool isListening;
  final SentencePracticeAttempt? attempt;

  /// Live partial transcript while [isListening]; empty otherwise. Used so
  /// the stale attempt chip is replaced with "Get ready…" / "Listening…"
  /// during the active mic session (TASK 12.2 §B).
  final String partialText;
  final bool armed;
  final ValueChanged<PlaybackSpeed> onSpeedChanged;
  final VoidCallback onPlay;
  final VoidCallback onMic;

  const _PagerCard({
    required this.line,
    required this.speed,
    required this.isPlaying,
    required this.isListening,
    required this.attempt,
    required this.partialText,
    required this.armed,
    required this.onSpeedChanged,
    required this.onPlay,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: BayanColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: BayanColors.onSurface.withValues(alpha: 0.07),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CharacterAvatar(name: line.character, size: 44),
                const SizedBox(width: 10),
                Text(
                  line.character,
                  style: BayanTypography.titleLarge.copyWith(
                    fontSize: 15,
                    color: BayanColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              line.english,
              textAlign: TextAlign.center,
              style: BayanTypography.headlineLarge.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: BayanColors.onSurface,
                height: 1.2,
              ),
            ),
            if (line.phonetic.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                line.phonetic,
                textAlign: TextAlign.center,
                style: BayanTypography.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  color: BayanColors.textMuted,
                ),
              ),
            ],
            if (line.arabic.isNotEmpty)
              ArabicVisibility(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    line.arabic,
                    textAlign: TextAlign.center,
                    style: BayanTypography.bodyLarge.copyWith(
                      fontFamily: BayanTypography.arabicFontFamily,
                      fontWeight: FontWeight.w700,
                      color: BayanColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            _SpeedPill(speed: speed, onChanged: onSpeedChanged),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BigCircle(
                  icon: isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                  bg: BayanColors.primary.withValues(alpha: 0.10),
                  fg: BayanColors.primary,
                  size: 44,
                  onTap: onPlay,
                ),
                const SizedBox(width: 24),
                _BigCircle(
                  icon: isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  bg: isListening
                      ? BayanColors.error
                      : BayanColors.successStrong,
                  fg: Colors.white,
                  elevated: true,
                  size: 58,
                  onTap: onMic,
                ),
              ],
            ),
            // Suppress the stale attempt chip while the mic is live — same
            // reasoning as ConversationBubble (TASK 12.2 §B).
            if (isListening) ...[
              const SizedBox(height: 14),
              _ListeningStrip(armed: armed, partialText: partialText),
            ] else if (attempt != null) ...[
              const SizedBox(height: 14),
              _AttemptChip(attempt: attempt!),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpeedPill extends StatelessWidget {
  final PlaybackSpeed speed;
  final ValueChanged<PlaybackSpeed> onChanged;
  const _SpeedPill({required this.speed, required this.onChanged});

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
          for (final s in PlaybackSpeed.values)
            GestureDetector(
              onTap: () => onChanged(s),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: s == speed
                      ? BayanColors.cardBg
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  s.label,
                  style: BayanTypography.labelMedium.copyWith(
                    color: s == speed
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

class _BigCircle extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;
  final bool elevated;
  final VoidCallback onTap;
  const _BigCircle({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.size,
    required this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
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
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, size: size * 0.44, color: fg),
        ),
      ),
    );
  }
}

/// Pager equivalent of ConversationBubble._ListeningStrip. Takes over the
/// chip position while the mic is live so the stale "Didn't catch that"
/// never reads as the current result (TASK 12.2 §B).
class _ListeningStrip extends StatelessWidget {
  final bool armed;
  final String partialText;
  const _ListeningStrip({required this.armed, required this.partialText});

  @override
  Widget build(BuildContext context) {
    final partial = partialText.trim();
    final text = !armed
        ? 'Get ready…'
        : (partial.isEmpty ? 'Listening…' : '"$partial"');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.graphic_eq_rounded,
          size: 16,
          color: BayanColors.primary,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: BayanTypography.bodySmall.copyWith(
              color: BayanColors.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _AttemptChip extends StatelessWidget {
  final SentencePracticeAttempt attempt;
  const _AttemptChip({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final a = attempt.assessment;
    if (a == null) {
      return Text(
        attempt.heard.isEmpty
            ? "Didn't catch that — try again."
            : 'Heard: "${attempt.heard}"',
        textAlign: TextAlign.center,
        style: BayanTypography.bodySmall.copyWith(
          color: BayanColors.textMuted,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    final pct = (a.score * 100).round();
    final passed = a.passed;
    final bg = passed ? BayanColors.successTint : BayanColors.warnTint;
    final fg = passed ? BayanColors.successFg : BayanColors.warnFg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.refresh_rounded,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: BayanTypography.bodySmall.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
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
  }
}

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;
  const _DotIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox(height: 8);
    final visible = count > 11 ? 11 : count;
    final start = (current - 5).clamp(0, (count - visible).clamp(0, count));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(visible, (i) {
          final idx = start + i;
          final active = idx == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? BayanColors.primary : BayanColors.dotInactive,
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}

class _MarkCompleteBar extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback? onTap;
  const _MarkCompleteBar({required this.isCompleted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: isCompleted
                  ? BayanColors.primary.withValues(alpha: 0.35)
                  : BayanColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            icon: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.check_rounded,
              size: 20,
            ),
            label: Text(
              isCompleted ? 'Completed' : 'Mark as complete',
              style: BayanTypography.labelLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
