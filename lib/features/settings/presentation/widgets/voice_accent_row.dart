import 'package:flutter/material.dart';

import '../../../../base/extensions/context_ext.dart';
import '../../../../core/utils/voice_preferences.dart';
import 'options_bottom_sheet.dart';
import 'settings_row.dart';
import 'value_with_stepper.dart';

/// Settings row for choosing between US and UK English for CDN audio. Reads
/// + writes the [AppVoicePreferences.accent] notifier directly — no bloc
/// needed since the singleton already mirrors the bloc-getter pattern.
class VoiceAccentRow extends StatelessWidget {
  const VoiceAccentRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    return ValueListenableBuilder<VoiceAccent>(
      valueListenable: AppVoicePreferences.instance.accent,
      builder: (context, accent, _) {
        return SettingsRow(
          icon: Icons.record_voice_over_outlined,
          title: l.settingsVoiceAccent,
          trailing: ValueWithStepper(value: _label(l, accent)),
          onTap: () => OptionsBottomSheet.show<VoiceAccent>(
            context: context,
            title: l.settingsVoiceAccent,
            current: accent,
            options: [
              OptionEntry(value: VoiceAccent.us, label: l.voiceAccentUs),
              OptionEntry(value: VoiceAccent.uk, label: l.voiceAccentUk),
            ],
            onSelect: AppVoicePreferences.instance.setAccent,
          ),
        );
      },
    );
  }

  String _label(dynamic l, VoiceAccent a) => switch (a) {
        VoiceAccent.us => l.voiceAccentUs as String,
        VoiceAccent.uk => l.voiceAccentUk as String,
      };
}
