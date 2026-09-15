import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

/// Sticky bottom bar for [GrammarLessonScreen] — circular "previous" button
/// (when available) + a primary "Next Rule" / "Finish Lesson" button.
class GrammarNextRuleBar extends StatelessWidget {
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const GrammarNextRuleBar({
    super.key,
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          children: [
            if (hasPrev) ...[
              Material(
                color: BayanColors.surfaceContainerLowest,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onPrev,
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: BayanColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm),
            ],
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: hasNext ? onNext : onFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BayanColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hasNext
                            ? context.localization.nextRule
                            : context.localization.finishLesson,
                        style: BayanTypography.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
