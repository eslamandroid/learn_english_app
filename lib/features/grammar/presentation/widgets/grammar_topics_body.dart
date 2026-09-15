import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../shared/enums/cefr_level.dart';
import '../../domain/entities/grammar_topic.dart';
import '../bloc/grammar_topics/grammar_topics_bloc.dart';
import '../bloc/grammar_topics/grammar_topics_event.dart';
import '../bloc/grammar_topics/grammar_topics_state.dart';
import 'grammar_overview_card.dart';
import 'grammar_tip_card.dart';
import 'grammar_topic_card.dart';

/// Scrollable body of [GrammarTopicsScreen] — overview header, expandable
/// topic cards, and a closing learning tip.
class GrammarTopicsBody extends StatelessWidget {
  final GrammarTopicsLoaded state;
  final CefrLevel level;

  const GrammarTopicsBody({
    super.key,
    required this.state,
    required this.level,
  });

  static IconData _iconFor(GrammarTopic topic) {
    // Topic id → glyph mapping. Falls through to a neutral default; once we
    // know the topic categorisation rules we can refine.
    switch (topic.id) {
      case 1:
        return Icons.text_fields_rounded;
      case 2:
        return Icons.person_outline_rounded;
      case 3:
        return Icons.directions_rounded;
      case 4:
        return Icons.style_outlined;
      case 5:
        return Icons.rocket_launch_rounded;
      case 6:
        return Icons.history_rounded;
      case 7:
        return Icons.schedule_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  static Color _accentFor(int topicId) {
    const palette = [
      BayanColors.primary,
      BayanColors.tertiary,
      BayanColors.secondary,
      BayanColors.a2Color,
      BayanColors.b1Color,
      BayanColors.b2Color,
      BayanColors.c1Color,
      BayanColors.c2Color,
    ];
    return palette[topicId % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final topics = state.topics;
    final bloc = context.read<GrammarTopicsBloc>();

    // For "Module N of M", use the first expanded topic as "current" — or
    // fall back to topic 1. Real progress will land in Phase 8.
    final currentTopicId = state.expandedTopicIds.isNotEmpty
        ? state.expandedTopicIds.first
        : null;
    final currentIndex = currentTopicId == null
        ? (topics.isEmpty ? 0 : 1)
        : (topics.indexWhere((t) => t.id == currentTopicId) + 1);

    final totalSubtopics = topics.fold<int>(
      0,
      (sum, t) => sum + t.subtopicCount,
    );
    final overallProgress =
        state.progress.overallProgress(totalSubtopics);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.containerPadding,
        AppConstants.spacingLg,
        AppConstants.containerPadding,
        AppConstants.spacingLg,
      ),
      children: [
        GrammarOverviewCard(
          level: level,
          currentIndex: currentIndex,
          totalCount: topics.length,
          progress: overallProgress,
        ),
        const SizedBox(height: AppConstants.spacingLg),
        for (final topic in topics) ...[
          GrammarTopicCard(
            topic: topic,
            icon: _iconFor(topic),
            iconColor: _accentFor(topic.id),
            iconBackground: _accentFor(topic.id).withValues(alpha: 0.14),
            isExpanded: state.expandedTopicIds.contains(topic.id),
            isLoadingSubtopics: state.loadingTopicIds.contains(topic.id),
            isLocked: false,
            subtopics: state.subtopicsByTopic[topic.id] ?? const [],
            progress: state.progress,
            onToggle: () =>
                bloc.add(ToggleTopicExpansion(topicId: topic.id)),
            onSubtopicTap: (sub) =>
                context.push('/grammar/${topic.id}/${sub.id}'),
          ),
          const SizedBox(height: AppConstants.spacingMd),
        ],
        GrammarTipCard(
          title: context.localization.grammarTipTitle,
          body: context.localization.grammarTipDefaultBody,
        ),
      ],
    );
  }
}
