import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../features/sentences/presentation/bloc/sentence_practice/sentence_practice_bloc.dart';
import '../../../../features/sentences/presentation/bloc/sentence_practice/sentence_practice_event.dart';
import '../../../../features/sentences/presentation/bloc/sentence_practice/sentence_practice_state.dart';
import '../../../../shared/enums/playback_speed.dart';
import '../../domain/entities/conversation_line.dart';
import '../bloc/conversation_player/conversation_player_bloc.dart';
import '../bloc/conversation_player/conversation_player_event.dart';
import '../bloc/conversation_player/conversation_player_state.dart';
import '../widgets/conversation_bubble.dart';

/// Chat view — scrollable list of bubbles alternating by character +
/// floating playback bar at the bottom.
///
/// Alignment rule (TASK 10 §6): the FIRST unique character to appear aligns
/// left; the second right; third left; and so on. Supports any number of
/// speakers, not just two.
class ConversationChatBody extends StatefulWidget {
  final int lessonId;
  const ConversationChatBody({super.key, required this.lessonId});

  @override
  State<ConversationChatBody> createState() => _ConversationChatBodyState();
}

class _ConversationChatBodyState extends State<ConversationChatBody> {
  final _scroll = ScrollController();
  final _bubbleKeys = <int, GlobalKey>{};
  int? _lastScrolledIndex;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Map<String, bool> _buildAlignmentMap(List<ConversationLine> lines) {
    final map = <String, bool>{};
    var next = false; // first speaker = left (false = alignRight:false)
    for (final l in lines) {
      map.putIfAbsent(l.character, () {
        final align = next;
        next = !next;
        return align;
      });
    }
    return map;
  }

  void _scrollToIfNeeded(int index) {
    if (_lastScrolledIndex == index) return;
    _lastScrolledIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _bubbleKeys[index];
      final ctx = key?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        alignment: 0.4,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConversationPlayerBloc, ConversationPlayerState>(
      // Only surface *new* non-null errors so a stale one doesn't re-fire a
      // snackbar on an unrelated state change.
      listenWhen: (p, c) =>
          c.errorMessage != null && c.errorMessage != p.errorMessage,
      listener: (ctx, state) {
        final msg = state.errorMessage;
        if (msg == null) return;
        ScaffoldMessenger.of(ctx)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ));
      },
      builder: (ctx, state) {
        if (state.isAutoPlaying) _scrollToIfNeeded(state.currentIndex);
        final playerBloc = ctx.read<ConversationPlayerBloc>();
        final practiceBloc = ctx.read<SentencePracticeBloc>();
        final alignment = _buildAlignmentMap(state.lines);

        return Stack(
          children: [
            BlocBuilder<SentencePracticeBloc, SentencePracticeState>(
              builder: (ctx, practice) {
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                  itemCount: state.lines.length,
                  itemBuilder: (c, i) {
                    final line = state.lines[i];
                    final isCurrent =
                        state.isAutoPlaying && i == state.currentIndex;
                    final isUpcoming =
                        state.isAutoPlaying && i > state.currentIndex;
                    final isListeningThis =
                        practice.activeSentenceId == line.id;
                    final key = _bubbleKeys.putIfAbsent(i, () => GlobalKey());
                    return KeyedSubtree(
                      key: key,
                      child: ConversationBubble(
                        line: line,
                        alignRight: alignment[line.character] ?? false,
                        isCurrent: isCurrent,
                        isUpcoming: isUpcoming,
                        isPlaying: state.playingLineId == line.id,
                        attempt: practice.attempts[line.id],
                        isListening: isListeningThis,
                        // Only forward the live partial for the bubble that
                        // actually owns the active mic session — otherwise
                        // every bubble would echo the same transcript.
                        partialText:
                            isListeningThis ? practice.partialText : '',
                        armed: isListeningThis && practice.armed,
                        onPlay: () => playerBloc
                            .add(PlayConversationSingle(line.id)),
                        onMic: isListeningThis
                            ? () => practiceBloc
                                .add(const StopSentenceCheck())
                            : () => practiceBloc.add(StartSentenceCheck(
                                  sentenceId: line.id,
                                  targetSentence: line.english,
                                  continuous: true,
                                )),
                      ),
                    );
                  },
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _FloatingControls(state: state),
            ),
          ],
        );
      },
    );
  }
}

class _FloatingControls extends StatelessWidget {
  final ConversationPlayerState state;
  const _FloatingControls({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ConversationPlayerBloc>();
    final showing = state.lines.length;
    final playing = state.isAutoPlaying && !state.isSinglePlay;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: BayanColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: BayanColors.onSurface.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _SpeedPill(
                speed: state.speed,
                onChanged: (s) => bloc.add(SetConversationSpeed(s)),
              ),
              const Spacer(),
              _CircleControl(
                icon: Icons.skip_previous_rounded,
                enabled: state.hasPrevious,
                onTap: () => bloc.add(const PreviousConversationLine()),
              ),
              const SizedBox(width: 8),
              _PlayButton(
                playing: playing,
                onTap: () => bloc.add(playing
                    ? const PauseConversationSequence()
                    : const PlayConversationSequence()),
              ),
              const SizedBox(width: 8),
              _CircleControl(
                icon: Icons.skip_next_rounded,
                enabled: state.hasNext,
                onTap: () => bloc.add(const NextConversationLine()),
              ),
              const Spacer(),
              Text(
                '${state.currentIndex + 1} / $showing',
                style: BayanTypography.labelLarge.copyWith(
                  fontSize: 13,
                  color: BayanColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
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
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

class _CircleControl extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _CircleControl({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 40,
          height: 40,
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
                : BayanColors.primary.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool playing;
  final VoidCallback onTap;
  const _PlayButton({required this.playing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: BayanColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: BayanColors.primary.withValues(alpha: 0.30),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
