import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../domain/entities/phonetic_table_item.dart';

class IpaTableWidget extends StatelessWidget {
  final List<PhoneticTableItem> items;
  const IpaTableWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: BayanColors.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _Row(item: items[i]),
            if (i < items.length - 1)
              const Divider(height: 1, color: BayanColors.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final PhoneticTableItem item;
  const _Row({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              item.title,
              style: BayanTypography.labelLarge.copyWith(
                color: BayanColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            flex: 2,
            child: Text(item.value, style: BayanTypography.bodyMedium),
          ),
        ],
      ),
    );
  }
}
