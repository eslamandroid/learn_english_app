import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../bloc/sentence_topics/sentence_topics_bloc.dart';
import '../bloc/sentence_topics/sentence_topics_event.dart';
import '../bloc/sentence_topics/sentence_topics_state.dart';
import '../widgets/sentence_lesson_args.dart';
import '../widgets/topic_card.dart';

class SentenceTopicsScreen extends StatelessWidget {
  const SentenceTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<SentenceTopicsBloc>()..add(const LoadSentenceTopics()),
      child: Scaffold(
        backgroundColor: BayanColors.screenBg,
        body: SafeArea(
          child: BlocBuilder<SentenceTopicsBloc, SentenceTopicsState>(
            builder: (context, state) {
              final bloc = context.read<SentenceTopicsBloc>();
              return Column(
                children: [
                  _TopicsHeader(
                    completedLessons: state is SentenceTopicsLoaded
                        ? state.completedLessons
                        : null,
                    totalLessons: state is SentenceTopicsLoaded
                        ? state.totalLessons
                        : null,
                    onBack: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.dashboard),
                  ),
                  const Divider(height: 1, color: BayanColors.divider),
                  Expanded(
                    child: switch (state) {
                      SentenceTopicsInitial() ||
                      SentenceTopicsLoading() =>
                        const Center(child: CircularProgressIndicator()),
                      SentenceTopicsError(:final message) => ErrorStateView(
                          message: message,
                          onRetry: () =>
                              bloc.add(const LoadSentenceTopics()),
                        ),
                      SentenceTopicsLoaded() => _TopicsList(state: state),
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

class _TopicsHeader extends StatelessWidget {
  final int? completedLessons;
  final int? totalLessons;
  final VoidCallback onBack;

  const _TopicsHeader({
    required this.completedLessons,
    required this.totalLessons,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 12),
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
                  'PRACTICE',
                  style: BayanTypography.labelMedium.copyWith(
                    fontSize: 11,
                    color: BayanColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1 * 11,
                  ),
                ),
                Text(
                  'Sentences',
                  style: BayanTypography.titleLarge.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: BayanColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (totalLessons != null && totalLessons! > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: BayanColors.primaryTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded,
                      size: 14, color: BayanColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '$completedLessons / $totalLessons lessons',
                    style: BayanTypography.labelMedium.copyWith(
                      fontSize: 13,
                      color: BayanColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TopicsList extends StatefulWidget {
  final SentenceTopicsLoaded state;
  const _TopicsList({required this.state});

  @override
  State<_TopicsList> createState() => _TopicsListState();
}

class _TopicsListState extends State<_TopicsList> {
  final _controller = ScrollController();
  final _itemKeys = <int, GlobalKey>{};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollExpandedIntoView(int topicId) {
    // After the next frame — once AnimatedSize has committed its layout — we
    // make sure the just-opened card's header is still on-screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _itemKeys[topicId];
      final ctx = key?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        alignment: 0, // top of the card at the top of the viewport
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final bloc = context.read<SentenceTopicsBloc>();

    return ListView.separated(
      controller: _controller,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: s.topics.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final topic = s.topics[i];
        final subtopics = s.subtopicsByTopic[topic.id] ?? const [];
        final key = _itemKeys.putIfAbsent(topic.id, () => GlobalKey());
        return KeyedSubtree(
          key: key,
          child: TopicCard(
            topic: topic,
            subtopics: subtopics,
            progress: s.progress,
            expanded: s.expandedTopicId == topic.id,
            onHeaderTap: () {
              final willExpand = s.expandedTopicId != topic.id;
              bloc.add(ToggleSentenceTopicExpanded(topic.id));
              if (willExpand) _scrollExpandedIntoView(topic.id);
            },
            onLessonTap: (sub) => context.push(
              AppRoutes.sentenceContent(topic.id, sub.id),
              extra: SentenceLessonArgs(
                subtopicTitle: sub.title,
                topicIconKey: topic.icon,
              ),
            ),
          ),
        );
      },
    );
  }
}
