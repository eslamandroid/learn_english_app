import 'package:flutter/material.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../l10n/share_localizations.dart';

class DashboardGreeting extends StatelessWidget {
  final String userName;
  final int streakDays;

  const DashboardGreeting({
    super.key,
    required this.userName,
    required this.streakDays,
  });

  String _timeGreeting(AppLocalizations l) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l.goodMorning(userName);
    if (hour < 18) return l.goodAfternoon(userName);
    return l.goodEvening(userName);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _timeGreeting(l),
          style: BayanTypography.headlineLarge.copyWith(
            color: BayanColors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l.streakMessage(streakDays),
          style: BayanTypography.bodyMedium.copyWith(
            color: BayanColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
