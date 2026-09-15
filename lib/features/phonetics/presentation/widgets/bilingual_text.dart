import 'package:flutter/material.dart';
import 'package:learn_english_app/core/theme/bayan_colors.dart';

import '../../../../core/utils/content_language.dart';

/// Shows English and Arabic together, reordered/restyled by the current
/// [AppContentLanguage] emphasis. The emphasized language uses [primary] and
/// is shown first; the other uses [secondary]. Empty values are skipped, so a
/// field with no translation simply shows one line.
///
/// When `AppContentLanguage.instance.showArabic` is `false`, the Arabic branch
/// is omitted entirely — only the English line renders. This is reactive:
/// flipping the Settings toggle rebuilds every subscriber.
class BilingualText extends StatelessWidget {
  final String? en;
  final String? ar;
  final TextStyle primary;
  final TextStyle secondary;
  final TextAlign? textAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final int? maxLines;
  final double gap;

  const BilingualText({
    super.key,
    required this.en,
    required this.ar,
    required this.primary,
    required this.secondary,
    this.textAlign,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.maxLines,
    this.gap = 2,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppContentLanguage.instance.showArabic,
      builder: (context, showAr, _) {
        return ValueListenableBuilder<ContentLang>(
          valueListenable: AppContentLanguage.instance.emphasis,
          builder: (context, lang, _) {
            final enText = en?.trim() ?? '';
            final arText = showAr ? (ar?.trim() ?? '') : '';
            final arFirst = lang == ContentLang.ar;

            // Arabic line forces the Cairo family so punctuation/digits inside
            // Arabic strings render in Cairo too — not just the Arabic glyphs
            // that would have hit Cairo via fontFamilyFallback.
            final arPrimary = primary.copyWith(fontFamily: 'Cairo',fontWeight: FontWeight.w600,color: BayanColors.textPrimary);
            final arSecondary = secondary.copyWith(fontFamily: 'Cairo',fontWeight: FontWeight.w600,color: BayanColors.textPrimary);

            final ordered = <(String, TextStyle)>[
              if (arFirst) ...[
                if (arText.isNotEmpty) (arText, arPrimary),
                if (enText.isNotEmpty) (enText, secondary),
              ] else ...[
                if (enText.isNotEmpty) (enText, primary),
                if (arText.isNotEmpty) (arText, arSecondary),
              ],
            ];

            if (ordered.isEmpty) return const SizedBox.shrink();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: crossAxisAlignment,
              children: [
                for (var i = 0; i < ordered.length; i++) ...[
                  if (i > 0) SizedBox(height: gap),
                  Text(
                    ordered[i].$1,
                    style: ordered[i].$2,
                    textAlign: textAlign,
                    maxLines: maxLines,
                    overflow:
                        maxLines != null ? TextOverflow.ellipsis : null,
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
