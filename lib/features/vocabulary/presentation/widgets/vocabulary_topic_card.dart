import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/widgets/arabic_visibility.dart';
import '../../domain/entities/vocabulary_topic.dart';
import 'vocabulary_progress_ring.dart';

/// One tile in the topic grid — colored icon square, progress ring, bilingual
/// title, and a status line (`N / M Words` or "Completed").
class VocabularyTopicCard extends StatelessWidget {
  final VocabularyTopic topic;
  final IconData icon;
  final Color accent;

  /// Words the learner has completed so far in this topic (0 for now — will
  /// wire to progress tracking later).
  final int completedWords;

  final VoidCallback onTap;

  const VocabularyTopicCard({
    super.key,
    required this.topic,
    required this.icon,
    required this.accent,
    required this.completedWords,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = topic.wordCount;
    final progress = total == 0 ? 0.0 : completedWords / total;
    final isDone = total > 0 && completedWords >= total;

    return Material(
      color: accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.18),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Icon(icon, color: accent, size: 22),
                  ),
                  const Spacer(),
                  VocabularyProgressRing(
                    progress: progress,
                    color: accent,
                    size: 40,
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Text(
                topic.title,
                style: BayanTypography.titleLarge.copyWith(
                  color: BayanColors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (topic.titleAr.isNotEmpty)
                ArabicVisibility(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      topic.titleAr,
                      style: BayanTypography.bodyMedium.copyWith(
                        color: BayanColors.onSurfaceVariant,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              const SizedBox(height: AppConstants.spacingSm),
              if (isDone)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: BayanTypography.bodySmall.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  total == 0
                      ? 'No words yet'
                      : '$completedWords / $total Words',
                  style: BayanTypography.bodySmall.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
