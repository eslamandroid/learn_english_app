import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/widgets/arabic_visibility.dart';
import '../../../progress/domain/entities/grammar_subtopic_status.dart';
import '../../domain/entities/grammar_subtopic.dart';

class GrammarLessonRow extends StatelessWidget {
  final GrammarSubtopic subtopic;
  final GrammarSubtopicStatus status;
  final VoidCallback onTap;

  const GrammarLessonRow({
    super.key,
    required this.subtopic,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isInProgress = status.isInProgress;
    final isCompleted = status.isCompleted;
    final isLocked = status.isLocked;

    final bg = isInProgress
        ? BayanColors.primary.withValues(alpha: 0.08)
        : isCompleted
            ? BayanColors.success.withValues(alpha: 0.06)
            : BayanColors.surfaceContainerLow;
    final border = isInProgress ? BayanColors.primary : Colors.transparent;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: AppConstants.spacingSm + 2,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Row(
            children: [
              _LeadingIcon(status: status),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(child: _Title(subtopic: subtopic, isLocked: isLocked)),
              const SizedBox(width: AppConstants.spacingSm),
              _TrailingBadge(status: status, ruleCount: subtopic.ruleCount),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final GrammarSubtopicStatus status;
  const _LeadingIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      GrammarSubtopicStatus.locked => (
          Icons.lock_rounded,
          BayanColors.onSurfaceVariant,
        ),
      GrammarSubtopicStatus.completed => (
          Icons.check_circle_rounded,
          BayanColors.success,
        ),
      GrammarSubtopicStatus.inProgress => (
          Icons.play_circle_outline_rounded,
          BayanColors.primary,
        ),
      GrammarSubtopicStatus.notStarted => (
          Icons.circle_outlined,
          BayanColors.onSurfaceVariant,
        ),
    };
    return Icon(icon, size: 22, color: color);
  }
}

class _Title extends StatelessWidget {
  final GrammarSubtopic subtopic;
  final bool isLocked;
  const _Title({required this.subtopic, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    final color = isLocked ? BayanColors.onSurfaceVariant : BayanColors.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtopic.title,
          style: BayanTypography.titleLarge.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtopic.titleAr.isNotEmpty)
          ArabicVisibility(
            child: Text(
              subtopic.titleAr,
              style: BayanTypography.bodySmall.copyWith(
                color: BayanColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _TrailingBadge extends StatelessWidget {
  final GrammarSubtopicStatus status;
  final int ruleCount;
  const _TrailingBadge({required this.status, required this.ruleCount});

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    return switch (status) {
      GrammarSubtopicStatus.inProgress => _Pill(
          label: l.continueLabel,
          fg: BayanColors.primary,
          bg: BayanColors.surfaceContainerLowest,
          border: BayanColors.primary,
        ),
      GrammarSubtopicStatus.completed => _Pill(
          label: l.lessonStatusCompleted,
          fg: BayanColors.success,
          bg: BayanColors.success.withValues(alpha: 0.12),
          border: Colors.transparent,
        ),
      GrammarSubtopicStatus.locked => _Pill(
          label: l.lessonStatusLocked,
          fg: BayanColors.onSurfaceVariant,
          bg: BayanColors.surfaceContainerHigh,
          border: Colors.transparent,
        ),
      GrammarSubtopicStatus.notStarted => Text(
          l.rulesCount(ruleCount),
          style: BayanTypography.labelMedium.copyWith(
            color: BayanColors.onSurfaceVariant,
          ),
        ),
    };
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  final Color border;
  const _Pill({
    required this.label,
    required this.fg,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm + 2,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Text(
        label,
        style: BayanTypography.labelMedium.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
