import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../progress/domain/entities/sentence_lesson_progress.dart';
import '../../domain/entities/sentence_subtopic.dart';

/// One row inside the expanded topic sublist. Shows:
///   • an index circle (grey / primary / success) tied to lesson state,
///   • title,
///   • status trailing: `Done` pill for complete, `N / M` + bar for started,
///     `M sentences · not started` for untouched.
class TopicLessonRow extends StatelessWidget {
  final int index;
  final SentenceSubtopic subtopic;
  final SentenceLessonProgress? lesson;
  final int? fallbackTotal;
  final VoidCallback onTap;

  const TopicLessonRow({
    super.key,
    required this.index,
    required this.subtopic,
    required this.lesson,
    required this.onTap,
    this.fallbackTotal,
  });

  @override
  Widget build(BuildContext context) {
    final completed = lesson?.isCompleted ?? false;
    final started = lesson?.isStarted ?? false;
    final total = lesson?.total ?? fallbackTotal ?? 0;
    final seen = lesson?.seen ?? 0;

    final (bg, fg) = switch ((completed, started)) {
      (true, _) => (BayanColors.successStrong, Colors.white),
      (_, true) => (BayanColors.primary, Colors.white),
      _ => (BayanColors.divider, BayanColors.textMuted),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingSm,
            vertical: AppConstants.spacingSm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IndexCircle(bg: bg, fg: fg, text: '$index'),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtopic.title,
                      style: BayanTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BayanColors.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _StatusLine(
                      completed: completed,
                      started: started,
                      total: total,
                      seen: seen,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              _Trailing(completed: completed, started: started),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndexCircle extends StatelessWidget {
  final Color bg;
  final Color fg;
  final String text;
  const _IndexCircle({required this.bg, required this.fg, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        text,
        style: BayanTypography.labelMedium.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final bool completed;
  final bool started;
  final int seen;
  final int total;

  const _StatusLine({
    required this.completed,
    required this.started,
    required this.seen,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return Row(
        children: [
          Expanded(
            child: _MiniBar(
              value: 1.0,
              color: BayanColors.successStrong,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            total > 0 ? '$total sentences' : '',
            style: BayanTypography.bodySmall.copyWith(
              color: BayanColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    if (started && total > 0) {
      return Row(
        children: [
          Expanded(
            child: _MiniBar(
              value: (seen / total).clamp(0, 1),
              color: BayanColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$seen / $total',
            style: BayanTypography.bodySmall.copyWith(
              color: BayanColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }
    return Text(
      total > 0
          ? '$total sentences · not started'
          : 'Not started',
      style: BayanTypography.bodySmall.copyWith(
        color: BayanColors.textMuted,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _MiniBar extends StatelessWidget {
  final double value;
  final Color color;
  const _MiniBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 5,
          backgroundColor: BayanColors.divider,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    );
  }
}

class _Trailing extends StatelessWidget {
  final bool completed;
  final bool started;
  const _Trailing({required this.completed, required this.started});

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: BayanColors.successTint,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Done',
          style: BayanTypography.labelMedium.copyWith(
            color: BayanColors.successFg,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
      );
    }
    return Icon(
      Icons.chevron_right_rounded,
      size: 20,
      color: started ? BayanColors.primary : BayanColors.textMuted,
    );
  }
}
