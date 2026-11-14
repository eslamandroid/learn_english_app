import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../domain/entities/vocabulary_subtopic.dart';
import 'vocabulary_subtopic_card.dart';

class VocabularySubtopicsBody extends StatelessWidget {
  final int topicId;
  final String? topicTitle;
  final List<VocabularySubtopic> subtopics;

  const VocabularySubtopicsBody({
    super.key,
    required this.topicId,
    required this.subtopics,
    this.topicTitle,
  });

  static IconData _iconFor(int subtopicId) {
    const glyphs = [
      Icons.diversity_3_rounded,
      Icons.favorite_rounded,
      Icons.accessibility_new_rounded,
      Icons.psychology_rounded,
      Icons.directions_run_rounded,
      Icons.local_florist_rounded,
      Icons.mood_rounded,
      Icons.school_rounded,
      Icons.child_care_rounded,
      Icons.self_improvement_rounded,
    ];
    return glyphs[(subtopicId - 1) % glyphs.length];
  }

  static Color _accentFor(int subtopicId) {
    const palette = [
      BayanColors.primary,
      BayanColors.a1Color,
      BayanColors.tertiary,
      BayanColors.b1Color,
      BayanColors.error,
      BayanColors.a2Color,
      BayanColors.b2Color,
      BayanColors.c1Color,
    ];
    return palette[subtopicId % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    if (subtopics.isEmpty) {
      return const Center(child: Text('No subtopics found for this topic.'));
    }
    final totalWords =
        subtopics.fold<int>(0, (sum, s) => sum + s.wordCount);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.containerPadding,
              AppConstants.spacingSm,
              AppConstants.containerPadding,
              AppConstants.spacingLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (topicTitle != null && topicTitle!.isNotEmpty)
                  Text(
                    topicTitle!,
                    style: BayanTypography.headlineMedium.copyWith(
                      color: BayanColors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${subtopics.length} subtopics · $totalWords Words',
                  style: BayanTypography.bodyMedium.copyWith(
                    color: BayanColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.containerPadding,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppConstants.spacingMd,
              crossAxisSpacing: AppConstants.spacingMd,
              childAspectRatio: 0.95,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final st = subtopics[i];
                return VocabularySubtopicCard(
                  subtopic: st,
                  icon: _iconFor(st.id),
                  accent: _accentFor(st.id),
                  completedWords: 0,
                  onTap: () => context.push(
                    '${AppRoutes.vocabulary}/$topicId/${st.id}',
                    extra: st.title,
                  ),
                );
              },
              childCount: subtopics.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppConstants.spacingLg),
        ),
      ],
    );
  }
}
