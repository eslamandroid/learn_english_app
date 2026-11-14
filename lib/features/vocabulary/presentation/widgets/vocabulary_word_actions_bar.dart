import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../bloc/vocabulary_words/vocabulary_words_bloc.dart';
import '../bloc/vocabulary_words/vocabulary_words_event.dart';
import '../bloc/vocabulary_words/vocabulary_words_state.dart';

/// Pinned bottom bar for the word-detail carousel — previous arrow (left),
/// "Add to My Word List" primary button (center), next arrow (right).
///
/// Reads the current index + total from [VocabularyWordsBloc] via a
/// [BlocSelector] so it rebuilds only on page changes, not on every
/// pronunciation or audio update.
class VocabularyWordActionsBar extends StatelessWidget {
  final VoidCallback? onAddToList;

  const VocabularyWordActionsBar({super.key, this.onAddToList});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BlocSelector<VocabularyWordsBloc, VocabularyWordsState, _NavData?>(
        selector:
            (state) =>
                state is VocabularyWordsLoaded
                    ? _NavData(
                      index: state.currentIndex,
                      total: state.words.length,
                    )
                    : null,
        builder: (context, nav) {
          if (nav == null || nav.total == 0) {
            return const SizedBox.shrink();
          }
          final bloc = context.read<VocabularyWordsBloc>();
          final hasPrev = nav.index > 0;
          final hasNext = nav.index < nav.total - 1;

          return Container(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.containerPadding,
              AppConstants.spacingMd,
              AppConstants.containerPadding,
              AppConstants.spacingMd,
            ),
            decoration: BoxDecoration(
              color: BayanColors.surfaceContainerLowest,
              border: Border(
                top: BorderSide(
                  color: BayanColors.outlineVariant.withValues(alpha: .55),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: BayanColors.onSurface.withValues(alpha: .06),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Row(
              children: [
                _ArrowButton(
                  icon: Icons.arrow_back_rounded,
                  enabled: hasPrev,
                  onTap:
                      hasPrev
                          ? () => bloc.add(
                            ChangeVocabularyWordIndex(index: nav.index - 1),
                          )
                          : null,
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAddToList,
                    icon: const Icon(Icons.bookmark_add_rounded),
                    label: const Text('Save this word'),
                    style: FilledButton.styleFrom(
                      backgroundColor: BayanColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull,
                        ),
                      ),
                      textStyle: BayanTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                _ArrowButton(
                  icon: Icons.arrow_forward_rounded,
                  enabled: hasNext,
                  onTap:
                      hasNext
                          ? () => bloc.add(
                            ChangeVocabularyWordIndex(index: nav.index + 1),
                          )
                          : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BayanColors.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      shape: CircleBorder(
        side: BorderSide(
          color: BayanColors.outlineVariant.withValues(alpha: .75),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(
            icon,
            color:
                enabled
                    ? BayanColors.primary
                    : BayanColors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _NavData {
  final int index;
  final int total;
  const _NavData({required this.index, required this.total});

  @override
  bool operator ==(Object other) =>
      other is _NavData && other.index == index && other.total == total;

  @override
  int get hashCode => Object.hash(index, total);
}
