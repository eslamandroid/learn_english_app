import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../domain/entities/grammar_rule_test.dart';

class GrammarTestCard extends StatelessWidget {
  final GrammarRuleTest test;
  final String? selected;
  final ValueChanged<String> onSelect;

  const GrammarTestCard({
    super.key,
    required this.test,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BayanColors.primary, BayanColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Text(
                context.localization.testYourKnowledge,
                style: BayanTypography.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.localization.chooseCorrectForm,
                  style: BayanTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  '"${test.question}"',
                  style: BayanTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                for (final option in test.options) ...[
                  _OptionTile(
                    label: option,
                    state: _stateFor(option),
                    onTap: selected == null ? () => onSelect(option) : null,
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _OptionState _stateFor(String option) {
    if (selected == null) return _OptionState.idle;
    if (option == test.correct) return _OptionState.correct;
    if (option == selected) return _OptionState.wrong;
    return _OptionState.disabled;
  }
}

enum _OptionState { idle, correct, wrong, disabled }

class _OptionTile extends StatelessWidget {
  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(state);
    return Material(
      color: colors.bg,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: BayanTypography.titleLarge.copyWith(
                    color: colors.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (state == _OptionState.correct)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                )
              else if (state == _OptionState.wrong)
                const Icon(
                  Icons.cancel_rounded,
                  color: Colors.white,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  ({Color bg, Color border, Color fg}) _colorsFor(_OptionState state) {
    switch (state) {
      case _OptionState.idle:
        return (
          bg: Colors.white.withValues(alpha: 0.18),
          border: Colors.transparent,
          fg: Colors.white,
        );
      case _OptionState.correct:
        return (
          bg: BayanColors.success.withValues(alpha: 0.85),
          border: Colors.white,
          fg: Colors.white,
        );
      case _OptionState.wrong:
        return (
          bg: BayanColors.error.withValues(alpha: 0.85),
          border: Colors.white,
          fg: Colors.white,
        );
      case _OptionState.disabled:
        return (
          bg: Colors.white.withValues(alpha: 0.08),
          border: Colors.transparent,
          fg: Colors.white.withValues(alpha: 0.55),
        );
    }
  }
}
