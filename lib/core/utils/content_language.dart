import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

enum ContentLang { en, ar }

/// App-wide state for bilingual content.
///
/// Two independent notifiers:
/// - [emphasis] — which language gets shown first when both are visible
///   (`ContentLang.en` by default). Affects ordering only, never the app
///   locale or layout direction.
/// - [showArabic] — whether Arabic content is shown at all in lesson/example
///   cards, list rows, headers, etc. When `false`, every widget that consults
///   it (directly via `ArabicVisibility` or indirectly via `BilingualText`)
///   collapses its Arabic branch.
///
/// Both values are persisted in [SharedPreferences] once [bind] has been
/// called at app boot.
class AppContentLanguage {
  AppContentLanguage._();
  static final AppContentLanguage instance = AppContentLanguage._();

  final ValueNotifier<ContentLang> emphasis = ValueNotifier(ContentLang.en);
  final ValueNotifier<bool> showArabic = ValueNotifier(true);

  SharedPreferences? _prefs;

  /// Reads persisted values from [prefs] and wires writes back. Call once at
  /// app boot — after the `@preResolve` `SharedPreferences` is available.
  void bind(SharedPreferences prefs) {
    _prefs = prefs;
    showArabic.value =
        prefs.getBool(AppConstants.prefShowArabicContent) ?? false;
    final stored = prefs.getString(AppConstants.prefContentEmphasisLang);
    if (stored == ContentLang.ar.name) {
      emphasis.value = ContentLang.ar;
    } else if (stored == ContentLang.en.name) {
      emphasis.value = ContentLang.en;
    }
  }

  ContentLang get value => emphasis.value;
  bool get arabicFirst => emphasis.value == ContentLang.ar;
  bool get arabicVisible => showArabic.value;

  void set(ContentLang lang) {
    emphasis.value = lang;
    _prefs?.setString(AppConstants.prefContentEmphasisLang, lang.name);
  }

  void setShowArabic(bool value) {
    showArabic.value = value;
    _prefs?.setBool(AppConstants.prefShowArabicContent, value);
  }

  void toggle() => set(arabicFirst ? ContentLang.en : ContentLang.ar);
}
