import 'package:flutter/material.dart';

import '../../../../base/extensions/context_ext.dart';
import '../../../../core/utils/voice_preferences.dart';
import 'options_bottom_sheet.dart';
import 'settings_row.dart';
import 'value_with_stepper.dart';

/// Settings row for choosing the audio voice gender. Combined with the
/// accent row, the two notifiers produce the four `us_male`/`us_female`/
/// `uk_male`/`uk_female` voice keys the CDN expects.
class VoiceGenderRow extends StatelessWidget {
  const VoiceGenderRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    return ValueListenableBuilder<VoiceGender>(
      valueListenable: AppVoicePreferences.instance.gender,
      builder: (context, gender, _) {
        return SettingsRow(
          icon: Icons.tune_rounded,
          title: l.settingsVoiceGender,
          trailing: ValueWithStepper(value: _label(l, gender)),
          onTap: () => OptionsBottomSheet.show<VoiceGender>(
            context: context,
            title: l.settingsVoiceGender,
            current: gender,
            options: [
              OptionEntry(value: VoiceGender.female, label: l.voiceGenderFemale),
              OptionEntry(value: VoiceGender.male, label: l.voiceGenderMale),
            ],
            onSelect: AppVoicePreferences.instance.setGender,
          ),
        );
      },
    );
  }

  String _label(dynamic l, VoiceGender g) => switch (g) {
        VoiceGender.female => l.voiceGenderFemale as String,
        VoiceGender.male => l.voiceGenderMale as String,
      };
}
