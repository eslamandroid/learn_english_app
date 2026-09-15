import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/enums/cefr_level.dart';

/// Top bar of the dashboard — brand mark + level pill + streak pill + avatar.
class DashboardTopBar extends StatelessWidget implements PreferredSizeWidget {
  final CefrLevel level;
  final int streakDays;
  final VoidCallback? onAvatarTap;

  const DashboardTopBar({
    super.key,
    required this.level,
    required this.streakDays,
    this.onAvatarTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.containerPadding,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: BayanColors.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              _Brand(name: context.localization.appBrandName),
              const Spacer(),
              _LevelPill(level: level),
              const SizedBox(width: AppConstants.spacingSm),
              _StreakPill(days: streakDays),
              const SizedBox(width: AppConstants.spacingSm),
              _Avatar(onTap: onAvatarTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  final String name;
  const _Brand({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.water_drop_rounded,
          color: BayanColors.primary,
          size: 22,
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: BayanTypography.headlineMedium.copyWith(
            color: BayanColors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _LevelPill extends StatelessWidget {
  final CefrLevel level;
  const _LevelPill({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: BayanColors.success.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        level.label,
        style: BayanTypography.labelLarge.copyWith(
          color: BayanColors.success,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int days;
  const _StreakPill({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm + 2,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: BayanColors.warning.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.flash_on_rounded,
            size: 14,
            color: BayanColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            '$days',
            style: BayanTypography.labelLarge.copyWith(
              color: BayanColors.warning,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final VoidCallback? onTap;
  const _Avatar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: BayanColors.surfaceContainerHigh,
          border: Border.all(color: BayanColors.outlineVariant),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.person_outline_rounded,
          size: 20,
          color: BayanColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
