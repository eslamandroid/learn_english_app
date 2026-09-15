import 'package:flutter/material.dart';

import '../../../../base/extensions/context_ext.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../core/usecases/get_selected_level.dart';
import '../../../../core/usecases/set_selected_level.dart';
import '../../../../core/utils/phoenix.dart';
import '../../../../di/di.dart';
import '../../../../shared/enums/cefr_level.dart';
import 'options_bottom_sheet.dart';
import 'settings_row.dart';
import 'value_with_stepper.dart';

/// Settings row that lets the user switch their CEFR level (A1 → C2). On
/// confirm, the new level is persisted via [SetSelectedLevel], then the
/// entire app subtree restarts via [Phoenix.rebirth] so every per-level
/// bloc/repo re-reads the new level from prefs.
class CefrLevelRow extends StatefulWidget {
  const CefrLevelRow({super.key});

  @override
  State<CefrLevelRow> createState() => _CefrLevelRowState();
}

class _CefrLevelRowState extends State<CefrLevelRow> {
  late CefrLevel _level;

  @override
  void initState() {
    super.initState();
    _level = getIt<GetSelectedLevel>().current();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    final description = _description(l, _level);
    return SettingsRow(
      icon: Icons.trending_up_rounded,
      title: l.settingsLevel,
      trailing: ValueWithStepper(
        value: l.cefrLevelOptionLabel(_level.label, description),
      ),
      onTap: () => _openPicker(context),
    );
  }

  void _openPicker(BuildContext context) {
    final l = context.localization;
    OptionsBottomSheet.show<CefrLevel>(
      context: context,
      title: l.settingsLevel,
      current: _level,
      options: [
        for (final lvl in CefrLevel.values)
          OptionEntry(
            value: lvl,
            label: lvl.label,
            subtitle: _description(l, lvl),
          ),
      ],
      onSelect: (picked) {
        if (picked == _level) return;
        _confirmAndRestart(context, picked);
      },
    );
  }

  Future<void> _confirmAndRestart(BuildContext context, CefrLevel target) async {
    final l = context.localization;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l.settingsRestartTitle),
        content: Text(l.settingsRestartBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: BayanColors.primary,
              foregroundColor: BayanColors.onPrimary,
              textStyle: BayanTypography.labelLarge,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(l.settingsRestartConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await getIt<SetSelectedLevel>().execute(target);
    if (!context.mounted) return;
    Phoenix.rebirth(context);
  }

  String _description(dynamic l, CefrLevel lvl) => switch (lvl) {
        CefrLevel.a1 => l.cefrLevelDescriptionA1 as String,
        CefrLevel.a2 => l.cefrLevelDescriptionA2 as String,
        CefrLevel.b1 => l.cefrLevelDescriptionB1 as String,
        CefrLevel.b2 => l.cefrLevelDescriptionB2 as String,
        CefrLevel.c1 => l.cefrLevelDescriptionC1 as String,
        CefrLevel.c2 => l.cefrLevelDescriptionC2 as String,
      };
}
