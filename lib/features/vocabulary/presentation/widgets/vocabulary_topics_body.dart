import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/enums/cefr_level.dart';
import '../../domain/entities/vocabulary_topic.dart';
import 'vocabulary_level_pill.dart';
import 'vocabulary_topic_card.dart';

/// Level chip + subtitle + 2-column grid of topic cards. Tapping a topic
/// pushes its subtopic screen at `/vocabulary/:topicId`.
class VocabularyTopicsBody extends StatelessWidget {
  final List<VocabularyTopic> topics;
  final CefrLevel level;

  const VocabularyTopicsBody({
    super.key,
    required this.topics,
    required this.level,
  });

  static IconData _iconFor(int topicId) {
    const glyphs = [
      Icons.people_alt_rounded,
      Icons.home_rounded,
      Icons.restaurant_rounded,
      Icons.checkroom_rounded,
      Icons.park_rounded,
      Icons.pets_rounded,
      Icons.directions_car_rounded,
      Icons.work_rounded,
      Icons.sports_soccer_rounded,
      Icons.medical_services_rounded,
      Icons.flight_rounded,
      Icons.shopping_bag_rounded,
      Icons.public_rounded,
      Icons.emoji_events_rounded,
    ];
    return glyphs[(topicId - 1) % glyphs.length];
  }

  static Color _accentFor(int topicId) {
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
    return palette[topicId % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final totalWords =
        topics.fold<int>(0, (sum, t) => sum + t.wordCount);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.containerPadding,
              AppConstants.spacingSm,
              AppConstants.containerPadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    VocabularyLevelPill(level: level),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(
                      child: Text(
                        level.description,
                        style: BayanTypography.bodyMedium.copyWith(
                          color: BayanColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.trending_up_rounded,
                      size: 18,
                      color: BayanColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalWords Words',
                      style: BayanTypography.bodyMedium.copyWith(
                        color: BayanColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMd),
                Text(
                  'Expand your core vocabulary with essential daily topics.',
                  style: BayanTypography.bodyMedium.copyWith(
                    color: BayanColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),
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
                final topic = topics[i];
                return VocabularyTopicCard(
                  topic: topic,
                  icon: _iconFor(topic.id),
                  accent: _accentFor(topic.id),
                  completedWords: 0,
                  onTap: () => context.push(
                    '${AppRoutes.vocabulary}/${topic.id}',
                    extra: topic.title,
                  ),
                );
              },
              childCount: topics.length,
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
