import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../../phonetics/presentation/bloc/pronunciation/pronunciation_bloc.dart';
import '../bloc/vocabulary_words/vocabulary_words_bloc.dart';
import '../bloc/vocabulary_words/vocabulary_words_event.dart';
import '../bloc/vocabulary_words/vocabulary_words_state.dart';
import '../widgets/vocabulary_word_actions_bar.dart';
import '../widgets/vocabulary_words_body.dart';

class VocabularyWordsScreen extends StatelessWidget {
  final int subtopicId;

  /// Optional title forwarded via `state.extra` — the subtopic name.
  final String? subtopicTitle;

  const VocabularyWordsScreen({
    super.key,
    required this.subtopicId,
    this.subtopicTitle,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  getIt<VocabularyWordsBloc>()
                    ..add(LoadVocabularyWords(subtopicId: subtopicId)),
        ),
        // Pronunciation-check bloc is shared across the pager so previously
        // attempted words remember their outcome when you swipe back.
        BlocProvider(create: (_) => getIt<PronunciationBloc>()),
      ],
      child: Scaffold(
        backgroundColor: BayanColors.background,
        bottomNavigationBar: const VocabularyWordActionsBar(),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEAF2FF), BayanColors.background],
              stops: [0, .32],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: BlocBuilder<VocabularyWordsBloc, VocabularyWordsState>(
              builder: (context, state) {
                final bloc = context.read<VocabularyWordsBloc>();
                final loaded =
                    state is VocabularyWordsLoaded ? state : null;
                return Column(
                  children: [
                    _LessonHeader(
                      title: subtopicTitle ?? 'Vocabulary',
                      onBack: context.pop,
                      progressIndex: loaded?.currentIndex,
                      progressTotal: loaded?.words.length,
                    ),
                    SizedBox(height: 10,),
                    Expanded(
                      child: switch (state) {
                        VocabularyWordsInitial() ||
                        VocabularyWordsLoading() => const _LoadingView(),
                        VocabularyWordsError(:final message) => ErrorStateView(
                          message: message,
                          onRetry:
                              () => bloc.add(
                                LoadVocabularyWords(subtopicId: subtopicId),
                              ),
                        ),
                        final VocabularyWordsLoaded loaded =>
                          VocabularyWordsBody(state: loaded, level: bloc.level),
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  /// Nullable — progress strip is skipped while the words list is still
  /// loading or has errored, since we don't yet have a total.
  final int? progressIndex;
  final int? progressTotal;

  const _LessonHeader({
    required this.title,
    required this.onBack,
    this.progressIndex,
    this.progressTotal,
  });

  @override
  Widget build(BuildContext context) {
    final showProgress =
        progressIndex != null && (progressTotal ?? 0) > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.containerPadding,
        AppConstants.spacingSm,
        AppConstants.containerPadding,
        AppConstants.spacingSm,
      ),
      child: Row(
        children: [
          _HeaderButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onPressed: onBack,
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VOCABULARY PRACTICE',
                  style: BayanTypography.labelMedium.copyWith(
                    color: BayanColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BayanTypography.titleLarge.copyWith(
                    color: BayanColors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (showProgress) ...[
                  const SizedBox(height: 6),
                  _HeaderProgress(
                    index: progressIndex!,
                    total: progressTotal!,
                  ),
                ],
              ],
            ),
          ),

        ],
      ),
    );
  }
}

/// Compact one-line progress strip that sits under the header title —
/// slim bar on the left filling available width, "N of M" on the right.
class _HeaderProgress extends StatelessWidget {
  final int index;
  final int total;
  const _HeaderProgress({required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : (index + 1) / total;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: BayanColors.surfaceContainerHigh,
              valueColor:
                  const AlwaysStoppedAnimation(BayanColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${index + 1} of $total',
          style: BayanTypography.labelMedium.copyWith(
            color: BayanColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BayanColors.surfaceContainerLowest.withValues(alpha: .86),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, color: BayanColors.onSurface),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox.square(
        dimension: 28,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }
}
