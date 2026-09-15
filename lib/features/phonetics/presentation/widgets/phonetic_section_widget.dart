import 'package:flutter/material.dart';

import '../../../../base/common_widget/image_view_from_net.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/cdn_config.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../domain/entities/phonetic_example.dart';
import '../../domain/entities/phonetic_section.dart';
import 'bilingual_text.dart';
import 'ipa_table_widget.dart';
import 'phonetic_example_table.dart';
import 'phonetic_pro_tip_card.dart';

/// Dispatches a section to the right card / inline block based on `type`.
class PhoneticSectionWidget extends StatelessWidget {
  final PhoneticSection section;
  final int? playingExampleId;
  final ValueChanged<PhoneticExample> onPlayExample;

  /// Whether the topic's phoneme clip is currently playing.
  final bool isSoundPlaying;

  /// Toggles playback of a `sound` section's bundled clip (asset name).
  final void Function(String assetName)? onToggleSound;

  const PhoneticSectionWidget({
    super.key,
    required this.section,
    required this.playingExampleId,
    required this.onPlayExample,
    this.isSoundPlaying = false,
    this.onToggleSound,
  });

  @override
  Widget build(BuildContext context) {
    switch (section.type) {
      case 'title':
        return _Heading(section: section, large: true);
      case 'subTitle':
        return _Heading(section: section, large: false);
      case 'tip':
        return PhoneticProTipCard(section: section);
      case 'table':
        return _SectionCard(
          title: section.title?.isNotEmpty == true ? section.title : null,
          titleAr: section.titleAr,
          icon: Icons.table_chart_rounded,
          child: IpaTableWidget(items: section.tableItems),
        );
      case 'content':
        return _ContentCard(
          section: section,
          playingExampleId: playingExampleId,
          onPlayExample: onPlayExample,
          isSoundPlaying: isSoundPlaying,
          onToggleSound: onToggleSound,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _Heading extends StatelessWidget {
  final PhoneticSection section;
  final bool large;
  const _Heading({required this.section, required this.large});

  @override
  Widget build(BuildContext context) {
    final title = section.title ?? '';
    final titleAr = section.titleAr ?? '';
    final body = section.body ?? '';
    final bodyAr = section.bodyAr ?? '';
    final hasTitle = title.isNotEmpty || titleAr.isNotEmpty;
    final hasBody = body.isNotEmpty || bodyAr.isNotEmpty;
    if (!hasTitle && !hasBody) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle)
            BilingualText(
              en: title,
              ar: titleAr,
              primary: large
                  ? BayanTypography.headlineMedium
                  : BayanTypography.titleLarge,
              secondary: BayanTypography.bodyMedium.copyWith(
                color: BayanColors.onSurfaceVariant,
              ),
              gap: 4,
            ),
          if (hasBody) ...[
            const SizedBox(height: AppConstants.spacingSm),
            BilingualText(
              en: body,
              ar: bodyAr,
              primary: BayanTypography.bodyMedium,
              secondary: BayanTypography.bodyMedium.copyWith(
                color: BayanColors.onSurfaceVariant,
              ),
              gap: 4,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String? title;
  final String? titleAr;
  final IconData? icon;
  final Widget child;

  const _SectionCard({
    required this.child,
    this.title,
    this.titleAr,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final hasTitle =
        (title?.isNotEmpty ?? false) || (titleAr?.isNotEmpty ?? false);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle || icon != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: BayanColors.primary),
                  const SizedBox(width: AppConstants.spacingSm),
                ],
                if (hasTitle)
                  Expanded(
                    child: BilingualText(
                      en: title,
                      ar: titleAr,
                      primary: BayanTypography.titleLarge,
                      secondary: BayanTypography.bodySmall.copyWith(
                        color: BayanColors.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
          ],
          child,
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final PhoneticSection section;
  final int? playingExampleId;
  final ValueChanged<PhoneticExample> onPlayExample;
  final bool isSoundPlaying;
  final void Function(String assetName)? onToggleSound;

  const _ContentCard({
    required this.section,
    required this.playingExampleId,
    required this.onPlayExample,
    required this.isSoundPlaying,
    required this.onToggleSound,
  });

  @override
  Widget build(BuildContext context) {
    final body = section.body ?? '';
    final hasExamples = section.examples.isNotEmpty;
    final hasHighlight = section.highlight.isNotEmpty;
    final sound = section.sound ?? '';
    final hasSound = sound.isNotEmpty;
    final images = [
      if (section.image != null) section.image!,
      if (section.image2 != null) section.image2!,
    ];


    final title = section.title?.isNotEmpty == true ? section.title : null;
    final bodyAr = section.bodyAr ?? '';
    final hasBody = body.isNotEmpty || bodyAr.isNotEmpty;

    return _SectionCard(
      title: title,
      titleAr: section.titleAr,
      icon: _iconFor(section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final img in images) ...[
            _SectionImage(name: img),
            const SizedBox(height: AppConstants.spacingMd),
          ],
          if (hasBody)
            BilingualText(
              en: body,
              ar: bodyAr,
              primary: BayanTypography.bodyMedium.copyWith(
                color: BayanColors.onSurface,
              ),
              secondary: BayanTypography.bodyMedium.copyWith(
                color: BayanColors.onSurfaceVariant,
              ),
              gap: 4,
            ),
          if (hasSound) ...[
            if (hasBody) const SizedBox(height: AppConstants.spacingMd),
            _SoundBlock(
              isPlaying: isSoundPlaying,
              onTap:
                  onToggleSound == null ? null : () => onToggleSound!(sound),
            ),
          ],
          if (hasHighlight) ...[
            if (hasBody || hasSound)
              const SizedBox(height: AppConstants.spacingMd),
            _HighlightChips(patterns: section.highlight),
          ],
          if (hasExamples) ...[
            if (hasBody || hasSound || hasHighlight)
              const SizedBox(height: AppConstants.spacingMd),
            PhoneticExampleTable(
              examples: section.examples,
              playingExampleId: playingExampleId,
              onPlay: onPlayExample,
            ),
          ],
        ],
      ),
    );
  }

  IconData? _iconFor(PhoneticSection s) {
    switch (s.superType) {
      case 'sectionWithImage':
        return Icons.image_outlined;
      case 'sound':
        return Icons.graphic_eq_rounded;
      case 'accent':
        return Icons.record_voice_over_rounded;
      default:
        return Icons.article_outlined;
    }
  }
}

class _SectionImage extends StatelessWidget {
  final String name;
  const _SectionImage({required this.name});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return ImageViewFromUrl(
          url: CdnConfig.phoneticSoundImage(name),
          width: width,
          height: width * 9 / 16,
          fit: BoxFit.contain,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          error: const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: BayanColors.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}

class _SoundBlock extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback? onTap;

  const _SoundBlock({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BayanColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: BayanColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: BayanColors.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPlaying ? 'Playing…' : 'Listen to the sound',
                      style: BayanTypography.titleLarge.copyWith(
                        color: BayanColors.primary,
                      ),
                    ),
                    Text(
                      'Tap to hear the pronunciation',
                      style: BayanTypography.bodySmall.copyWith(
                        color: BayanColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.graphic_eq_rounded,
                color: BayanColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightChips extends StatelessWidget {
  final List<String> patterns;
  const _HighlightChips({required this.patterns});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Common spellings',
          style: BayanTypography.labelLarge.copyWith(
            color: BayanColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Wrap(
          spacing: AppConstants.spacingSm,
          runSpacing: AppConstants.spacingSm,
          children: [
            for (final p in patterns)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMd,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: BayanColors.primary.withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  p,
                  style: BayanTypography.labelLarge.copyWith(
                    color: BayanColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
