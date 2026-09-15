import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/widgets/arabic_visibility.dart';
import '../../domain/entities/grammar_rule_example.dart';
import 'highlighted_text.dart';

class GrammarExampleCard extends StatelessWidget {
  final GrammarRuleExample example;
  final bool isSpeaking;
  final VoidCallback onSpeak;

  const GrammarExampleCard({
    super.key,
    required this.example,
    required this.isSpeaking,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final ar = example.textAr ?? '';
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HighlightedText(
                  text: example.textEn,
                  highlights: example.mustHighlight,
                  baseStyle: BayanTypography.titleLarge.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: BayanColors.onSurface,
                  ),
                ),
                if (ar.isNotEmpty)
                  ArabicVisibility(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          ar,
                          style: BayanTypography.bodySmall.copyWith(
                            color: BayanColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          _PlayButton(isSpeaking: isSpeaking, onTap: onSpeak),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isSpeaking;
  final VoidCallback onTap;
  const _PlayButton({required this.isSpeaking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BayanColors.primary.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
            size: 22,
            color: BayanColors.primary,
          ),
        ),
      ),
    );
  }
}
