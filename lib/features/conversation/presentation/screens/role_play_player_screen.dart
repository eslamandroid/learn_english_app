import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../di/di.dart';
import '../../../../features/sentences/presentation/bloc/sentence_practice/sentence_practice_bloc.dart';
import '../../../../features/sentences/presentation/bloc/sentence_practice/sentence_practice_event.dart';
import '../../../../features/sentences/presentation/bloc/sentence_practice/sentence_practice_state.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../domain/entities/conversation_line.dart';
import '../bloc/role_play/role_play_bloc.dart';
import '../bloc/role_play/role_play_event.dart';
import '../bloc/role_play/role_play_state.dart';
import '../widgets/character_avatar.dart';
import '../widgets/conversation_bubble.dart';
import '../widgets/role_play_your_turn_card.dart';
import 'role_play_result_screen.dart';

/// Main role-play surface. Hosts [RolePlayBloc] (sequence + results) and
/// [SentencePracticeBloc] (mic + SentenceAssessor from Task 06, reused as-is
/// — the task spec explicitly forbids a new assessor).
///
/// Flow:
///   • Non-user line → `ConversationBubble` from Task 10 (unmodified).
///   • Current user line → `RolePlayYourTurnCard`.
///   • Passed user line → compact success-tinted bubble.
///   • Upcoming lines → locked placeholder (no text — preserves surprise).
///
/// A `BlocListener<SentencePracticeBloc>` watches for new assessed attempts
/// on the current user line and forwards them to [RolePlayBloc]; no custom
/// speech code lives here.
class RolePlayPlayerScreen extends StatelessWidget {
  final int lessonId;
  final String character;
  final String? lessonTitle;

  const RolePlayPlayerScreen({
    super.key,
    required this.lessonId,
    required this.character,
    this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<RolePlayBloc>()
            ..add(LoadRolePlay(lessonId: lessonId, character: character)),
        ),
        BlocProvider(create: (_) => getIt<SentencePracticeBloc>()),
      ],
      child: _RolePlayBody(
        lessonTitle: lessonTitle,
        character: character,
      ),
    );
  }
}

class _RolePlayBody extends StatefulWidget {
  final String character;
  final String? lessonTitle;
  const _RolePlayBody({required this.character, this.lessonTitle});

  @override
  State<_RolePlayBody> createState() => _RolePlayBodyState();
}

class _RolePlayBodyState extends State<_RolePlayBody> {
  final _scroll = ScrollController();
  final _bubbleKeys = <int, GlobalKey>{};

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToIfNeeded(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _bubbleKeys[index];
      final ctx = key?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.35,
      );
    });
  }

  void _navigateToResults(BuildContext ctx) {
    final roleBloc = ctx.read<RolePlayBloc>();
    final s = roleBloc.state;
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => RolePlayResultScreen(
          character: widget.character,
          lines: s.lines,
          results: s.results,
          onTryAgain: () {
            Navigator.of(ctx).pop();
            roleBloc.add(const RolePlayRestart());
          },
          onContinue: () {
            Navigator.of(ctx).pop();
            if (ctx.mounted) ctx.pop(); // back to lessons
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BayanColors.screenBg,
      appBar: AppBar(
        backgroundColor: BayanColors.screenBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: BayanColors.onSurface,
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: BlocBuilder<RolePlayBloc, RolePlayState>(
          buildWhen: (p, c) =>
              p.selectedCharacter != c.selectedCharacter ||
              p.currentIndex != c.currentIndex ||
              p.lines.length != c.lines.length,
          builder: (ctx, s) => _HeaderStrip(
            character: widget.character,
            lessonTitle: widget.lessonTitle,
            progress: s.progress,
          ),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          // Finished → push results.
          BlocListener<RolePlayBloc, RolePlayState>(
            listenWhen: (p, c) => c.phase == RolePlayPhase.finished,
            listener: (ctx, s) => _navigateToResults(ctx),
          ),
          // Scroll to the current line whenever the pointer moves.
          BlocListener<RolePlayBloc, RolePlayState>(
            listenWhen: (p, c) => p.currentIndex != c.currentIndex,
            listener: (ctx, s) => _scrollToIfNeeded(s.currentIndex),
          ),
          // Surface audio / lookup errors.
          BlocListener<RolePlayBloc, RolePlayState>(
            listenWhen: (p, c) =>
                c.errorMessage != null && c.errorMessage != p.errorMessage,
            listener: (ctx, s) {
              final msg = s.errorMessage;
              if (msg == null) return;
              ScaffoldMessenger.of(ctx)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(msg),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ));
            },
          ),
          // The one piece of cross-bloc wiring: when a new assessed attempt
          // lands in SentencePracticeState for the current user line, hand
          // it to RolePlayBloc. Fail-states (noSpeech / denied / etc.) also
          // bounce back to waitingForUser via onStopMic.
          BlocListener<SentencePracticeBloc, SentencePracticeState>(
            listenWhen: (p, c) {
              final role = context.read<RolePlayBloc>().state;
              final line = role.currentLine;
              if (line == null) return false;
              return p.attempts[line.id] != c.attempts[line.id];
            },
            listener: (ctx, practice) {
              final roleBloc = ctx.read<RolePlayBloc>();
              final line = roleBloc.state.currentLine;
              if (line == null) return;
              final att = practice.attempts[line.id];
              if (att == null) return;
              if (att.outcome == SentencePracticeOutcome.assessed &&
                  att.assessment != null) {
                roleBloc.add(RolePlayUserAttemptResult(
                  lineId: line.id,
                  assessment: att.assessment!,
                ));
              } else {
                // No speech / permission / unavailable — return to idle so
                // the user can try again without a stuck mic UI.
                roleBloc.add(const RolePlayStopUserMic());
              }
            },
          ),
        ],
        child: BlocBuilder<RolePlayBloc, RolePlayState>(
          builder: (ctx, state) {
            if (state.phase == RolePlayPhase.loading && state.lines.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.phase == RolePlayPhase.error && state.lines.isEmpty) {
              return ErrorStateView(
                message:
                    state.errorMessage ?? 'Could not load this role-play.',
                onRetry: () => ctx.read<RolePlayBloc>().add(
                      LoadRolePlay(
                        lessonId: 0,
                        character: widget.character,
                      ),
                    ),
              );
            }
            return Stack(
              children: [
                ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                  itemCount: state.lines.length,
                  itemBuilder: (c, i) {
                    final line = state.lines[i];
                    final key = _bubbleKeys.putIfAbsent(i, () => GlobalKey());
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: KeyedSubtree(
                        key: key,
                        child: _lineWidget(ctx, state, i, line),
                      ),
                    );
                  },
                ),
                if (state.phase == RolePlayPhase.waitingForUser ||
                    state.phase == RolePlayPhase.checking)
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _BottomHint(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _lineWidget(
    BuildContext ctx,
    RolePlayState state,
    int index,
    ConversationLine line,
  ) {
    final isUserLine = line.character == state.selectedCharacter;
    final roleBloc = ctx.read<RolePlayBloc>();
    final practiceBloc = ctx.read<SentencePracticeBloc>();

    if (!isUserLine) {
      final isCurrent = state.currentIndex == index &&
          state.phase == RolePlayPhase.autoPlaying;
      final isUpcoming = index > state.currentIndex;
      // alignRight derived from first-appearance order of this character
      // among non-user characters (user owns ONE side, everyone else
      // shares the other). Keeps the chat flow readable.
      final isLeftSpeaker = index.isEven;
      return ConversationBubble(
        line: line,
        alignRight: !isLeftSpeaker,
        isCurrent: isCurrent,
        isUpcoming: isUpcoming,
        isPlaying: state.playingLineId == line.id,
        attempt: null,
        isListening: false,
        onPlay: () {},
        onMic: () {},
      );
    }

    // User lines.
    if (index < state.currentIndex) {
      // Already passed.
      final result = state.results[line.id];
      return _PassedUserBubble(line: line, result: result);
    }
    if (index == state.currentIndex) {
      final preview = state.playingLineId == line.id;
      return RolePlayYourTurnCard(
        line: line,
        isChecking: state.phase == RolePlayPhase.checking,
        isPreviewPlaying: preview,
        onPreview: () => roleBloc.add(const RolePlayPreviewUserLine()),
        onMicTap: () {
          if (state.phase == RolePlayPhase.checking) {
            practiceBloc.add(const StopSentenceCheck());
            roleBloc.add(const RolePlayStopUserMic());
          } else {
            // Clear any stale attempt and arm the mic.
            practiceBloc
                ..add(ClearSentenceAttempt(sentenceId: line.id))
                ..add(StartSentenceCheck(
                  sentenceId: line.id,
                  targetSentence: line.english,
                ));
            roleBloc.add(const RolePlayStartUserMic());
          }
        },
      );
    }
    // Upcoming user line — hide the text.
    return const _LockedPlaceholder();
  }
}

class _HeaderStrip extends StatelessWidget {
  final String character;
  final String? lessonTitle;
  final double progress;

  const _HeaderStrip({
    required this.character,
    required this.lessonTitle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: BayanColors.primaryTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CharacterAvatar(name: character, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Playing $character',
                    style: BayanTypography.labelMedium.copyWith(
                      fontSize: 12,
                      color: BayanColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 4,
            backgroundColor: BayanColors.divider,
            valueColor: const AlwaysStoppedAnimation(BayanColors.primary),
          ),
        ),
      ],
    );
  }
}

class _PassedUserBubble extends StatelessWidget {
  final ConversationLine line;
  final RoleLineResult? result;
  const _PassedUserBubble({required this.line, required this.result});

  @override
  Widget build(BuildContext context) {
    final pct = ((result?.bestScore ?? 0) * 100).round();
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.84,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: BayanColors.successStrong.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: BayanColors.successStrong.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.english,
                style: BayanTypography.titleLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: BayanColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 14, color: BayanColors.successFg),
                  const SizedBox(width: 4),
                  Text(
                    'You said this · $pct%',
                    style: BayanTypography.bodySmall.copyWith(
                      color: BayanColors.successFg,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedPlaceholder extends StatelessWidget {
  const _LockedPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.70,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: BayanColors.divider.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: BayanColors.divider,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 15, color: BayanColors.textMuted),
              const SizedBox(width: 6),
              Text(
                '• • •',
                style: BayanTypography.titleLarge.copyWith(
                  fontSize: 15,
                  color: BayanColors.textMuted,
                  letterSpacing: 3,
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

class _BottomHint extends StatelessWidget {
  const _BottomHint();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: BayanColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: BayanColors.onSurface.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mic_rounded,
                  size: 15, color: BayanColors.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Say your line to continue the conversation',
                  style: BayanTypography.bodySmall.copyWith(
                    color: BayanColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
