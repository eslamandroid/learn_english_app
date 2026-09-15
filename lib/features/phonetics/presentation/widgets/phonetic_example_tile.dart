import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/widgets/arabic_visibility.dart';
import '../../domain/entities/phonetic_example.dart';

class PhoneticExampleTile extends StatelessWidget {
  final PhoneticExample example;
  final bool isPlaying;
  final VoidCallback onPlay;

  const PhoneticExampleTile({
    super.key,
    required this.example,
    required this.isPlaying,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPlay,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: BoxDecoration(
            color: isPlaying
                ? BayanColors.primaryContainer.withValues(alpha: 0.18)
                : BayanColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: isPlaying
                  ? BayanColors.primary
                  : BayanColors.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: BayanColors.primary,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Icon(
                  isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: BayanColors.onPrimary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(example.word, style: BayanTypography.titleLarge),
                    if (example.phonetic != null &&
                        example.phonetic!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        example.phonetic!,
                        style: BayanTypography.bodyMedium.copyWith(
                          color: BayanColors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (example.wordAr != null && example.wordAr!.isNotEmpty)
                      ArabicVisibility(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            example.wordAr!,
                            style: BayanTypography.bodySmall.copyWith(
                              color: BayanColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
