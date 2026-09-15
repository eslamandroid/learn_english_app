import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

/// Sticky bottom CTA for the phonetic detail screen. Switches between a
/// primary "Mark as completed" button and a green "Completed" confirmation
/// once the topic is marked done.
class PhoneticCompleteBar extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onMarkComplete;

  const PhoneticCompleteBar({
    super.key,
    required this.isCompleted,
    required this.onMarkComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.containerPadding,
          AppConstants.spacingSm,
          AppConstants.containerPadding,
          AppConstants.spacingMd,
        ),
        color: BayanColors.background,
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: isCompleted ? null : onMarkComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted
                  ? BayanColors.success.withValues(alpha: 0.18)
                  : BayanColors.primary,
              disabledBackgroundColor:
                  BayanColors.success.withValues(alpha: 0.18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.task_alt_rounded,
                  color: isCompleted ? BayanColors.success : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  isCompleted
                      ? l.lessonStatusCompleted
                      : l.markAsCompleted,
                  style: BayanTypography.titleLarge.copyWith(
                    color: isCompleted ? BayanColors.success : Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
