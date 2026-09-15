import 'package:flutter/material.dart';
import 'package:learn_english_app/base/base.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../core/utils/content_language.dart';
import '../../../../shared/enums/cefr_level.dart';

class GrammarLessonHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String? titleAr;
  final CefrLevel level;
  final double progress;
  final VoidCallback onBack;

  const GrammarLessonHeader({
    super.key,
    required this.title,
    required this.titleAr,
    required this.level,
    required this.progress,
    required this.onBack,
  });

  // Generous enough for typical 1–3 line titles. AppBar slots get cropped
  // beyond this; corpus subtopic titles top out around two lines in either
  // language.
  @override
  Size get preferredSize => const Size.fromHeight(150);

  @override
  Widget build(BuildContext context) {
    final ar = titleAr ?? '';
    return Material(
      color: BayanColors.surfaceContainerLow,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingXs,
            AppConstants.spacingXs,
            AppConstants.spacingSm,
            AppConstants.spacingMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: BayanColors.primary,
                    splashRadius: 22,
                  ),
                  const Spacer(),
                  _LevelPill(level: level),
                ],
              ),
              const SizedBox(height: AppConstants.spacingXs),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMd,
                ),
                child: ValueListenableBuilder<bool>(
                  valueListenable: AppContentLanguage.instance.showArabic,
                  builder: (context, showAr, _) {
                    final renderAr = showAr && ar.isNotEmpty;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            softWrap: true,
                            style: BayanTypography.titleLarge.copyWith(
                              color: BayanColors.primary,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (renderAr) ...[
                          const SizedBox(width: AppConstants.spacingMd),
                          Expanded(
                            child: Text(
                              ar,
                              softWrap: true,
                              textAlign: TextAlign.right,
                              style: BayanTypography.bodyMedium.copyWith(
                                color: BayanColors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: BayanColors.surfaceContainerHigh,
                  valueColor:
                      const AlwaysStoppedAnimation(BayanColors.primary),
                ),
              ).paddingSymmetric(horizontal: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  final CefrLevel level;
  const _LevelPill({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm + 2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: BayanColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            level.label,
            style: BayanTypography.labelMedium.copyWith(
              color: BayanColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: BayanColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
