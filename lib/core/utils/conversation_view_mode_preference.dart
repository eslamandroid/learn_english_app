import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

enum ConversationViewMode { chat, pager }

/// Persists the user's preferred Talk-tab view mode (Chat ↔ Pager) across
/// sessions. Mirrors [SentencesViewModePreference] exactly — call [bind] once
/// at app boot (after `@preResolve` SharedPreferences is available), then
/// subscribe to [mode] from any widget via `ValueListenableBuilder`.
class ConversationViewModePreference {
  ConversationViewModePreference._();
  static final ConversationViewModePreference instance =
      ConversationViewModePreference._();

  final ValueNotifier<ConversationViewMode> mode =
      ValueNotifier(ConversationViewMode.chat);

  SharedPreferences? _prefs;

  void bind(SharedPreferences prefs) {
    _prefs = prefs;
    final stored = prefs.getString(AppConstants.prefConversationViewMode);
    if (stored == ConversationViewMode.pager.name) {
      mode.value = ConversationViewMode.pager;
    }
    // Default (chat) is already set.
  }

  void set(ConversationViewMode value) {
    mode.value = value;
    _prefs?.setString(AppConstants.prefConversationViewMode, value.name);
  }
}
