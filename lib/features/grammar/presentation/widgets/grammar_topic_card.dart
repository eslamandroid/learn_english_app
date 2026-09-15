import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/extensions.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/widgets/arabic_visibility.dart';
import '../../../progress/domain/entities/grammar_progress.dart';
import '../../domain/entities/grammar_subtopic.dart';
import '../../domain/entities/grammar_topic.dart';
import 'grammar_lesson_row.dart';

/// One topic tile — collapsed shows icon + title + bilingual subtitle plus a
/// thin progress bar. Expanded reveals the subtopics underneath, each rendered
/// in its current lock/completed/in-progress state.
class GrammarTopicCard extends StatelessWidget {
  final GrammarTopic topic;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final bool isExpanded;
  final bool isLoadingSubtopics;
  final bool isLocked;
  final List<GrammarSubtopic> subtopics;
  final GrammarProgress progress;
  final VoidCallback onToggle;
  final ValueChanged<GrammarSubtopic> onSubtopicTap;

  const GrammarTopicCard({
    super.key,
    required this.topic,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.isExpanded,
    required this.isLoadingSubtopics,
    required this.isLocked,
    required this.subtopics,
    required this.progress,
    required this.onToggle,
    required this.onSubtopicTap,
  });

  double get _topicProgress =>
      progress.topicProgress(subtopics.map((s) => s.id).toList());

  @override
  Widget build(BuildContext context) {
    final subtopicIdsInOrder = subtopics.map((s) => s.id).toList();
    return Container(
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLocked ? null : onToggle,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: iconBackground,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusMd,
                            ),
                          ),
                          child: Icon(icon, color: iconColor, size: 22),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        Expanded(
                          child: _Title(
                            topic: topic,
                            progress: _topicProgress,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingSm),
                        if (isLocked)
                          const Icon(
                            Icons.lock_rounded,
                            size: 18,
                            color: BayanColors.onSurfaceVariant,
                          )
                        else
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: BayanColors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    if (subtopics.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacingSm),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusFull),
                        child: LinearProgressIndicator(
                          value: _topicProgress.clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor: BayanColors.surfaceContainerHigh,
                          valueColor: AlwaysStoppedAnimation(iconColor),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded && !isLocked) ...[
            const Divider(height: 1, color: BayanColors.outlineVariant),
            if (isLoadingSubtopics)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppConstants.spacingMd,
                ),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacingSm,
                  AppConstants.spacingSm,
                  AppConstants.spacingSm,
                  AppConstants.spacingSm,
                ),
                child: Column(
                  children: [
                    8.ph,
                    for (var i = 0; i < subtopics.length; i++) ...[
                      GrammarLessonRow(
                        subtopic: subtopics[i],
                        status: progress.statusFor(
                          subtopics[i].id,
                          subtopicIdsInOrder,
                        ),
                        onTap: () => onSubtopicTap(subtopics[i]),
                      ),
                      if (i < subtopics.length - 1)
                        const SizedBox(height: AppConstants.spacingMd),
                    ],
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final GrammarTopic topic;
  final double progress;
  const _Title({required this.topic, required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0.0, 1.0) * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                topic.title,
                style: BayanTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (topic.titleAr.isNotEmpty)
              ArabicVisibility(
                child: Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      '(${topic.titleAr})',
                      style: BayanTypography.bodyMedium.copyWith(
                        color: BayanColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '$pct%',
          style: BayanTypography.bodySmall.copyWith(
            color: BayanColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
