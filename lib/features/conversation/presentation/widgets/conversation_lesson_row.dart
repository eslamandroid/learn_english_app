import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/widgets/arabic_visibility.dart';
import '../../domain/entities/conversation_lesson.dart';
import 'character_avatar.dart';

/// One row in the lessons list — avatars of the first two speakers overlap
/// (TASK 10 §9), followed by title + Arabic + duration + line count + state.
class ConversationLessonRow extends StatelessWidget {
  final ConversationLesson lesson;
  final List<String> previewCharacters;
  final bool isCompleted;
  final bool isInProgress;
  final VoidCallback onTap;

  /// Optional secondary action that opens the Role-play select screen for
  /// this lesson. The main [onTap] still opens the Listen player — the
  /// Role-play button sits next to the state badge and never swallows the
  /// row's primary tap (per TASK 13 §1 "لا تغيّر سلوك الضغط الأساسي").
  final VoidCallback? onRolePlayTap;

  const ConversationLessonRow({
    super.key,
    required this.lesson,
    required this.previewCharacters,
    required this.isCompleted,
    required this.isInProgress,
    required this.onTap,
    this.onRolePlayTap,
  });

  String _durationLabel() {
    final s = lesson.durationSeconds;
    final m = s ~/ 60;
    final r = s % 60;
    return '$m:${r.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BayanColors.cardBg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: BayanColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: isInProgress
                ? Border.all(color: BayanColors.primary, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: BayanColors.onSurface.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _OverlappingAvatars(characters: previewCharacters),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: BayanTypography.titleLarge.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: BayanColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    ArabicVisibility(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          lesson.titleAr,
                          style: BayanTypography.bodySmall.copyWith(
                            fontFamily: BayanTypography.arabicFontFamily,
                            color: BayanColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 13, color: BayanColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          _durationLabel(),
                          style: BayanTypography.bodySmall.copyWith(
                            color: BayanColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.format_list_bulleted_rounded,
                            size: 13, color: BayanColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          '${lesson.lineCount} lines',
                          style: BayanTypography.bodySmall.copyWith(
                            color: BayanColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (onRolePlayTap != null) ...[
                _RolePlayShortcut(onTap: onRolePlayTap!),
                const SizedBox(width: 6),
              ],
              _StateBadge(
                isCompleted: isCompleted,
                isInProgress: isInProgress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RolePlayShortcut extends StatelessWidget {
  final VoidCallback onTap;
  const _RolePlayShortcut({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Role-play this lesson',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BayanColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.record_voice_over_rounded,
              size: 18,
              color: BayanColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlappingAvatars extends StatelessWidget {
  final List<String> characters;
  const _OverlappingAvatars({required this.characters});

  @override
  Widget build(BuildContext context) {
    final preview = characters.take(2).toList();
    const avatarSize = 36.0;
    const overlap = 14.0;
    return SizedBox(
      width: avatarSize + (preview.length > 1 ? overlap : 0),
      height: avatarSize,
      child: Stack(
        children: [
          if (preview.isNotEmpty)
            Positioned(
              left: 0,
              child: CharacterAvatar(
                name: preview[0],
                size: avatarSize,
                borderWidth: 2,
              ),
            ),
          if (preview.length > 1)
            Positioned(
              left: overlap,
              child: CharacterAvatar(
                name: preview[1],
                size: avatarSize,
                borderWidth: 2,
              ),
            ),
        ],
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  final bool isCompleted;
  final bool isInProgress;
  const _StateBadge({required this.isCompleted, required this.isInProgress});

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: BayanColors.successTint,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded,
                size: 14, color: BayanColors.successFg),
            const SizedBox(width: 3),
            Text(
              'Done',
              style: BayanTypography.labelMedium.copyWith(
                color: BayanColors.successFg,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }
    if (isInProgress) {
      return Text(
        'Continue',
        style: BayanTypography.labelMedium.copyWith(
          color: BayanColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      );
    }
    return const Icon(Icons.chevron_right_rounded,
        color: BayanColors.textMuted);
  }
}
