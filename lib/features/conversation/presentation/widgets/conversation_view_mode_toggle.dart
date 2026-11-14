import 'package:flutter/material.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../core/utils/conversation_view_mode_preference.dart';

/// Segmented pill: 💬 Chat ↔ ⬛ Pager — mirrors SentenceViewModeToggle.
/// Writes to [ConversationViewModePreference.instance] directly.
class ConversationViewModeToggle extends StatelessWidget {
  const ConversationViewModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ConversationViewMode>(
      valueListenable: ConversationViewModePreference.instance.mode,
      builder: (context, mode, _) {
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: BayanColors.primaryTint,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Segment(
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                active: mode == ConversationViewMode.chat,
                onTap: () => ConversationViewModePreference.instance
                    .set(ConversationViewMode.chat),
              ),
              _Segment(
                icon: Icons.view_carousel_rounded,
                label: 'Pager',
                active: mode == ConversationViewMode.pager,
                onTap: () => ConversationViewModePreference.instance
                    .set(ConversationViewMode.pager),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Segment({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? BayanColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? Colors.white : BayanColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: BayanTypography.labelMedium.copyWith(
                color: active ? Colors.white : BayanColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
