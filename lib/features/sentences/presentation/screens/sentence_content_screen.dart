import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../core/utils/sentences_view_mode_preference.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../bloc/sentence_content/sentence_content_bloc.dart';
import '../bloc/sentence_content/sentence_content_event.dart';
import '../bloc/sentence_content/sentence_content_state.dart';
import '../bloc/sentence_practice/sentence_practice_bloc.dart';
import '../bloc/sentence_practice/sentence_practice_event.dart';
import '../bloc/sentence_practice/sentence_practice_state.dart';
import '../widgets/sentence_card_row.dart';
import '../widgets/sentence_pager_view.dart';
import '../widgets/sentence_view_mode_toggle.dart';

/// Lesson screen — Cards mode (one sentence per page) or List mode
/// (scrollable list). Picks between them based on [SentencesViewModePreference].
class SentenceContentScreen extends StatelessWidget {
  final int subtopicId;
  final String? subtopicTitle;
  final String? topicIconKey;

  const SentenceContentScreen({
    super.key,
    required this.subtopicId,
    this.subtopicTitle,
    this.topicIconKey,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<SentenceContentBloc>()
            ..add(LoadSentenceContent(subtopicId: subtopicId)),
        ),
        BlocProvider(create: (_) => getIt<SentencePracticeBloc>()),
      ],
      child: Scaffold(
        backgroundColor: BayanColors.screenBg,
        body: SafeArea(
          child: BlocBuilder<SentenceContentBloc, SentenceContentState>(
            builder: (context, contentState) {
              final contentBloc = context.read<SentenceContentBloc>();
              return Column(
                children: [
                  _Header(
                    title: subtopicTitle ?? 'Lesson',
                    onBack: () => context.canPop()
                        ? context.pop()
                        : context.go('/sentences'),
                  ),
                  const Divider(height: 1, color: BayanColors.divider),
                  Expanded(
                    child: switch (contentState) {
                      SentenceContentInitial() ||
                      SentenceContentLoading() =>
                        const _LoadingView(),
                      SentenceContentError(:final message) => ErrorStateView(
                          message: message,
                          onRetry: () => contentBloc.add(
                            LoadSentenceContent(subtopicId: subtopicId),
                          ),
                        ),
                      SentenceContentLoaded(
                        :final sentences,
                        :final playingId,
                        :final isCompleted,
                      ) =>
                        sentences.isEmpty
                            ? const EmptyStateView(
                                icon: Icons.translate_rounded,
                                title: 'No sentences yet',
                                message:
                                    'Sentences for this topic will appear here.',
                              )
                            : _Body(
                                subtopicId: subtopicId,
                                topicIconKey: topicIconKey,
                                sentences: sentences,
                                playingId: playingId,
                                isCompleted: isCompleted,
                              ),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: BayanColors.onSurface,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SENTENCES',
                  style: BayanTypography.labelMedium.copyWith(
                    fontSize: 11,
                    color: BayanColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1 * 11,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BayanTypography.titleLarge.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: BayanColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const SentenceViewModeToggle(),
        ],
      ),
    );
  }
}

// ─── Body (switches on view mode) ────────────────────────────────────────────

class _Body extends StatelessWidget {
  final int subtopicId;
  final String? topicIconKey;
  final List sentences;
  final int? playingId;
  final bool isCompleted;

  const _Body({
    required this.subtopicId,
    required this.topicIconKey,
    required this.sentences,
    required this.playingId,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SentencePracticeBloc, SentencePracticeState>(
      builder: (context, practice) {
        return ValueListenableBuilder<SentencesViewMode>(
          valueListenable: SentencesViewModePreference.instance.mode,
          builder: (context, viewMode, _) {
            final isCards = viewMode == SentencesViewMode.pager;
            return Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Expanded(
                        child: isCards
                            ? SentencePagerView(
                                sentences: sentences.cast(),
                                playingId: playingId,
                                practiceState: practice,
                                subtopicId: subtopicId,
                                topicIconKey: topicIconKey,
                              )
                            : _ListBody(
                                sentences: sentences.cast(),
                                playingId: playingId,
                                practice: practice,
                                subtopicId: subtopicId,
                                topicIconKey: topicIconKey,
                              ),
                      ),
                      _MarkCompleteBar(
                        isCompleted: isCompleted,
                        onTap: isCompleted
                            ? null
                            : () => context.read<SentenceContentBloc>().add(
                                MarkSentenceContentComplete(
                                  subtopicId: subtopicId,
                                ),
                              ),
                        showFadeGradient: !isCards,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─── List mode body ──────────────────────────────────────────────────────────

class _ListBody extends StatelessWidget {
  final List sentences;
  final int? playingId;
  final SentencePracticeState practice;
  final int subtopicId;
  final String? topicIconKey;

  const _ListBody({
    required this.sentences,
    required this.playingId,
    required this.practice,
    required this.subtopicId,
    required this.topicIconKey,
  });

  @override
  Widget build(BuildContext context) {
    final contentBloc = context.read<SentenceContentBloc>();
    final practiceBloc = context.read<SentencePracticeBloc>();
    final practised = practice.attempts.values
        .where((a) => a.outcome == SentencePracticeOutcome.assessed)
        .length;

    return CustomScrollView(
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _ListHeaderRow(
              total: sentences.length,
              practised: practised,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: sentences.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final s = sentences[i];
              final isListeningThis =
                  practice.activeSentenceId == s.id;
              final attempt = practice.attempts[s.id];
              return SentenceCardRow(
                sentence: s,
                topicIconKey: topicIconKey,
                isPlaying: playingId == s.id,
                onPlayTap: () =>
                    contentBloc.add(PlaySentenceAudio(sentenceId: s.id)),
                accent: practice.accent,
                speed: practice.speed,
                onAccentChanged: practiceBloc.setAccent,
                onSpeedChanged: practiceBloc.setSpeed,
                isListening: isListeningThis,
                armed: isListeningThis && practice.armed,
                partialText: isListeningThis ? practice.partialText : '',
                attempt: attempt,
                onMicTap: isListeningThis
                    ? () => practiceBloc.add(const StopSentenceCheck())
                    : () => practiceBloc.add(
                          StartSentenceCheck(
                            sentenceId: s.id,
                            targetSentence: s.english,
                          ),
                        ),
                onTryAgain: () => practiceBloc
                    .add(ClearSentenceAttempt(sentenceId: s.id)),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _ListHeaderRow extends StatelessWidget {
  final int total;
  final int practised;
  const _ListHeaderRow({required this.total, required this.practised});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$total sentences',
          style: BayanTypography.labelLarge.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: BayanColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (practised > 0)
          Row(
            children: [
              Icon(Icons.check_rounded,
                  size: 14, color: BayanColors.successStrong),
              const SizedBox(width: 4),
              Text(
                '$practised practised',
                style: BayanTypography.labelLarge.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: BayanColors.successStrong,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ─── Loading view ────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading sentences…',
            style: BayanTypography.bodyMedium.copyWith(
              color: BayanColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mark as complete bar ────────────────────────────────────────────────────

class _MarkCompleteBar extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback? onTap;

  /// List mode fades the content into the screen bg behind the button.
  final bool showFadeGradient;

  const _MarkCompleteBar({
    required this.isCompleted,
    required this.onTap,
    required this.showFadeGradient,
  });

  @override
  Widget build(BuildContext context) {
    final button = Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: isCompleted
                ? BayanColors.primary.withValues(alpha: .35)
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
    );

    if (!showFadeGradient) return button;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BayanColors.screenBg.withValues(alpha: 0),
            BayanColors.screenBg,
            BayanColors.screenBg,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: button,
    );
  }
}
