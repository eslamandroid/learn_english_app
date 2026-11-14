import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../progress/domain/entities/sentences_progress.dart';
import '../../domain/entities/sentence_subtopic.dart';
import '../../domain/entities/sentence_topic.dart';
import 'sentence_topic_illustration.dart';
import 'topic_lesson_row.dart';

/// Topic card for the redesigned sentences topics screen.
///
/// Header is always visible (illustration + title + progress summary + bar +
/// expand chevron). Expanded sublist appears below in a [BayanColors.wellBg]
/// panel. Expansion is controlled by the parent so only one card is open at a
/// time (per TASK_sentences_ui_redesign §2).
class TopicCard extends StatelessWidget {
  final SentenceTopic topic;
  final List<SentenceSubtopic> subtopics;
  final SentencesProgress progress;
  final bool expanded;
  final VoidCallback onHeaderTap;
  final void Function(SentenceSubtopic) onLessonTap;

  const TopicCard({
    super.key,
    required this.topic,
    required this.subtopics,
    required this.progress,
    required this.expanded,
    required this.onHeaderTap,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final (done, total) = progress.topicCounts(
      subtopics.map((s) => s.id).toList(growable: false),
    );
    final value = total == 0 ? 0.0 : done / total;
    final allDone = total > 0 && done == total;
    final accent =
        allDone ? BayanColors.successStrong : BayanColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: BayanColors.cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: BayanColors.onSurface.withValues(alpha: .06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _Header(
            topic: topic,
            done: done,
            total: total,
            value: value,
            accent: accent,
            allDone: allDone,
            expanded: expanded,
            onTap: onHeaderTap,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? _Sublist(
                    subtopics: subtopics,
                    progress: progress,
                    onLessonTap: onLessonTap,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final SentenceTopic topic;
  final int done;
  final int total;
  final double value;
  final Color accent;
  final bool allDone;
  final bool expanded;
  final VoidCallback onTap;

  const _Header({
    required this.topic,
    required this.done,
    required this.total,
    required this.value,
    required this.accent,
    required this.allDone,
    required this.expanded,
    required this.onTap,
  });

  String _summary() {
    if (total == 0) return '${topic.sentenceCount} sentences';
    if (done == 0) return '$total lessons';
    if (done == total) return '$total lessons · all done';
    return '$done of $total lessons done';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 96),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: BayanColors.tileTint,
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: SentenceTopicIllustration(
                  iconKey: topic.icon,
                  size: 68,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: BayanTypography.titleLarge.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: BayanColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _summary(),
                      style: BayanTypography.bodySmall.copyWith(
                        color: BayanColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: value,
                              minHeight: 6,
                              backgroundColor: BayanColors.divider,
                              valueColor: AlwaysStoppedAnimation(accent),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(value * 100).round()}%',
                          style: BayanTypography.labelMedium.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _Chevron(expanded: expanded),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  final bool expanded;
  const _Chevron({required this.expanded});

  @override
  Widget build(BuildContext context) {
    final bg = expanded ? BayanColors.primary : BayanColors.primaryTint;
    final fg = expanded ? Colors.white : BayanColors.primary;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: AnimatedRotation(
        turns: expanded ? 0.5 : 0,
        duration: const Duration(milliseconds: 200),
        child: Icon(Icons.keyboard_arrow_down_rounded, color: fg, size: 20),
      ),
    );
  }
}

class _Sublist extends StatelessWidget {
  final List<SentenceSubtopic> subtopics;
  final SentencesProgress progress;
  final void Function(SentenceSubtopic) onLessonTap;

  const _Sublist({
    required this.subtopics,
    required this.progress,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    if (subtopics.isEmpty) {
      return const SizedBox(width: double.infinity);
    }
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: BayanColors.wellBg,
        border: Border(
          top: BorderSide(color: BayanColors.divider, width: 1),
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
      child: Column(
        children: [
          for (var i = 0; i < subtopics.length; i++)
            TopicLessonRow(
              index: i + 1,
              subtopic: subtopics[i],
              lesson: progress.lessonFor(subtopics[i].id),
              onTap: () => onLessonTap(subtopics[i]),
            ),
        ],
      ),
    );
  }
}
