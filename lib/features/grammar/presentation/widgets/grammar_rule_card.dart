import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/cdn_config.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../domain/entities/grammar_rule.dart';
import '../../domain/entities/grammar_rule_description.dart';
import 'arabic_translation_block.dart';
import 'highlighted_text.dart';
import 'must_english_card.dart';

class GrammarRuleCard extends StatelessWidget {
  final GrammarRule rule;

  /// Optional override for the small uppercase tagline under the title.
  /// Defaults to the localized `grammarCoreEssential` string.
  final String? tagline;

  const GrammarRuleCard({
    super.key,
    required this.rule,
    this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            title: rule.title ?? l.ruleNumber(rule.id),
            tagline: tagline ?? l.grammarCoreEssential,
          ),
          if (rule.image != null && rule.image!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingMd),
            _RuleImage(name: rule.image!),
          ],
          for (final d in rule.descriptions) ...[
            const SizedBox(height: AppConstants.spacingMd),
            _DescriptionBlock(description: d),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String tagline;
  const _Header({required this.title, required this.tagline});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: BayanColors.primary,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.text_snippet_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: BayanTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tagline,
                style: BayanTypography.labelMedium.copyWith(
                  color: BayanColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DescriptionBlock extends StatelessWidget {
  final GrammarRuleDescription description;
  const _DescriptionBlock({required this.description});

  @override
  Widget build(BuildContext context) {
    final en = description.textEn ?? '';
    final ar = description.textAr ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (en.isNotEmpty)
          HighlightedText(
            text: en,
            highlights: description.mustHighlight,
            baseStyle: BayanTypography.bodyLarge.copyWith(
              color: BayanColors.onSurface,
              fontSize: 16,
              height: 1.55,
            ),
          ),
        if (ar.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacingMd),
          ArabicTranslationBlock(text: ar),
        ],
        if (description.image != null && description.image!.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacingMd),
          _RuleImage(name: description.image!),
        ],
        if (description.mustHighlight.isNotEmpty &&
            description.mustHighlight.length <= 3) ...[
          const SizedBox(height: AppConstants.spacingMd),
          MustEnglishCard(
            body: context.localization.focusOnWhileReading(
              description.mustHighlight.map((s) => '"$s"').join(', '),
            ),
          ),
        ],
      ],
    );
  }
}

class _RuleImage extends StatelessWidget {
  final String name;
  const _RuleImage({required this.name});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Image.network(
        CdnConfig.grammarImage(name),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
