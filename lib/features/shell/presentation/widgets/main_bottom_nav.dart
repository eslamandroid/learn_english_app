import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';

class MainBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const MainBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Bottom nav used by `MainShellScreen`. Every tab shows its icon and label
/// at all times; the active tab swaps to the filled glyph + tints both the
/// icon and the label primary, sitting on a soft rounded-square primary
/// background.
class MainBottomNav extends StatelessWidget {
  final List<MainBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BayanColors.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, -1.5),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: AppConstants.spacingMd,
        bottom: MediaQuery.of(context).viewPadding.bottom,
        left: AppConstants.spacingXs,
        right: AppConstants.spacingXs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++)
            _NavItem(
              item: items[i],
              isActive: currentIndex == i,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final MainBottomNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm + 2,
        ),
        decoration: isActive
            ? BoxDecoration(
                color: BayanColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              size: 26,
              color: isActive
                  ? BayanColors.primary
                  : BayanColors.onSurface,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: BayanTypography.bodyMedium.copyWith(
                color: isActive
                    ? BayanColors.primary
                    : BayanColors.onSurface,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `BuildContext` helper to switch branches from anywhere inside the shell.
extension MainShellRouter on BuildContext {
  void switchToBranch(int index) {
    StatefulNavigationShell.of(this).goBranch(index);
  }
}
