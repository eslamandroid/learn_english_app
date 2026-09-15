import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

/// Reusable single-choice bottom sheet — header, list of options, check mark
/// on the currently selected one. Tap an option → [onSelect] fires with that
/// option's `value`, the sheet closes itself.
///
/// Generic so it works for any enum/value type without per-row plumbing.
class OptionsBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<OptionEntry<T>> options;
  final T current;
  final ValueChanged<T> onSelect;

  const OptionsBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.current,
    required this.onSelect,
  });

  /// Convenience static that shows the sheet via `showModalBottomSheet`.
  static Future<void> show<T>({
    required BuildContext context,
    required String title,
    required List<OptionEntry<T>> options,
    required T current,
    required ValueChanged<T> onSelect,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: BayanColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      builder: (_) => OptionsBottomSheet<T>(
        title: title,
        options: options,
        current: current,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppConstants.spacingSm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: BayanColors.outlineVariant,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.containerPadding,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: BayanTypography.titleLarge),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          for (final opt in options)
            ListTile(
              onTap: () {
                Navigator.pop(context);
                onSelect(opt.value);
              },
              title: Text(
                opt.label,
                style: BayanTypography.bodyLarge.copyWith(
                  color: opt.value == current
                      ? BayanColors.primary
                      : BayanColors.onSurface,
                  fontWeight: opt.value == current
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
              subtitle: opt.subtitle == null
                  ? null
                  : Text(
                      opt.subtitle!,
                      style: BayanTypography.bodySmall.copyWith(
                        color: BayanColors.onSurfaceVariant,
                      ),
                    ),
              trailing: opt.value == current
                  ? const Icon(Icons.check_rounded,
                      color: BayanColors.primary)
                  : null,
            ),
          const SizedBox(height: AppConstants.spacingMd),
        ],
      ),
    );
  }
}

class OptionEntry<T> {
  final T value;
  final String label;
  final String? subtitle;

  const OptionEntry({
    required this.value,
    required this.label,
    this.subtitle,
  });
}
