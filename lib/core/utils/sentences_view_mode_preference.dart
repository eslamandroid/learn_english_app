import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

enum SentencesViewMode { list, pager }

/// Persists the user's preferred sentence view mode (List ↔ Pager) across
/// sessions. Mirrors the [AppVoicePreferences] singleton pattern — call
/// [bind] once at app boot, then subscribe to [mode] from any widget.
class SentencesViewModePreference {
  SentencesViewModePreference._();
  static final SentencesViewModePreference instance =
      SentencesViewModePreference._();

  final ValueNotifier<SentencesViewMode> mode =
      ValueNotifier(SentencesViewMode.list);

  SharedPreferences? _prefs;

  /// Reads persisted value and wires writes back. Call once at app boot
  /// after the `@preResolve` [SharedPreferences] is available.
  void bind(SharedPreferences prefs) {
    _prefs = prefs;
    final stored = prefs.getString(AppConstants.prefSentencesViewMode);
    if (stored == SentencesViewMode.pager.name) {
      mode.value = SentencesViewMode.pager;
    }
    // Default (list) is already set — no else needed.
  }

  void set(SentencesViewMode value) {
    mode.value = value;
    _prefs?.setString(AppConstants.prefSentencesViewMode, value.name);
  }
}
