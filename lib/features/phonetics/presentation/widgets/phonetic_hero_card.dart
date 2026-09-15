import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/widgets/arabic_visibility.dart';
import '../../domain/entities/phonetic_topic.dart';

/// Centered phoneme + play button + example word, shown at the top of the
/// phonetic detail screen. Mirrors the uploaded design: `k • k ▶` then the
/// example words (`candy - cane`).
class PhoneticHeroCard extends StatelessWidget {
  final PhoneticTopic topic;

  /// Sound asset name (e.g. `consonants_k`) — when non-null a play button is
  /// shown next to the phoneme.
  final String? soundAsset;
  final bool isPlaying;
  final VoidCallback? onTogglePlay;

  const PhoneticHeroCard({
    super.key,
    required this.topic,
    this.soundAsset,
    this.isPlaying = false,
    this.onTogglePlay,
  });

  String get _headline => (topic.phoneTitle?.isNotEmpty ?? false)
      ? topic.phoneTitle!
      : topic.title;

  String get _word {
    final raw = topic.word ?? '';
    if (raw.isEmpty) return '';
    return raw
        .split(RegExp(r'[\n,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    final word = _word;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                _headline,
                textAlign: TextAlign.center,
                style: BayanTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: BayanColors.textPrimary
                ),
              ),
            ),
            if (soundAsset != null) ...[
              const SizedBox(width: AppConstants.spacingSm),
              _PlayButton(isPlaying: isPlaying, onTap: onTogglePlay),
            ],
          ],
        ),
        if (word.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            word,
            textAlign: TextAlign.center,
            style: BayanTypography.titleLarge.copyWith(
              color: BayanColors.onSurface,
            ),
          ),
        ] else if (topic.titleAr.isNotEmpty)
          ArabicVisibility(
            child: Padding(
              padding: const EdgeInsets.only(top: AppConstants.spacingXs),
              child: Text(
                topic.titleAr,
                textAlign: TextAlign.center,
                style: BayanTypography.bodyMedium.copyWith(
                  color: BayanColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback? onTap;

  const _PlayButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: BayanColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
            color: BayanColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
