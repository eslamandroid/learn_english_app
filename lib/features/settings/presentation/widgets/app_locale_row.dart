import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../base/extensions/context_ext.dart';
import '../../../language/presentation/bloc/language_bloc.dart';
import '../../../language/presentation/bloc/language_event.dart';
import '../../../language/presentation/bloc/language_state.dart';
import 'options_bottom_sheet.dart';
import 'settings_row.dart';
import 'value_with_stepper.dart';

/// Settings row that drives the app-wide [Locale] via the existing
/// [LanguageBloc] (which already powers `MaterialApp.locale` in `main.dart`).
/// Dispatching [ChangeLanguageEvent] is enough — `MaterialApp` rebuilds with
/// the new locale, every `AppLocalizations.of(context)` reflects it.
class AppLocaleRow extends StatelessWidget {
  const AppLocaleRow({super.key});

  static const _screenId = 'settings_app_locale_row';

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        final code = state.currentLanguage?.code ?? 'en';
        return SettingsRow(
          icon: Icons.language_rounded,
          title: l.settingsAppLanguage,
          trailing: ValueWithStepper(value: _label(l, code)),
          onTap: () => OptionsBottomSheet.show<String>(
            context: context,
            title: l.settingsAppLanguage,
            current: code,
            options: [
              OptionEntry(value: 'en', label: l.english),
              OptionEntry(value: 'ar', label: l.arabic),
            ],
            onSelect: (picked) => context.read<LanguageBloc>().add(
                  ChangeLanguageEvent(
                    languageCode: picked,
                    screenId: _screenId,
                  ),
                ),
          ),
        );
      },
    );
  }

  String _label(dynamic l, String code) =>
      code == 'ar' ? l.arabic as String : l.english as String;
}
