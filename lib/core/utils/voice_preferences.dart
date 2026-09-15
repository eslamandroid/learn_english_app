import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

enum VoiceAccent { us, uk }

enum VoiceGender { male, female }

/// App-wide selection of CDN audio voice. The CDN's [voiceKey] string maps
/// onto the four `{accent}_{gender}` combinations the catalog publishes
/// (`us_male`, `us_female`, `uk_male`, `uk_female`).
///
/// Mirrors the [AppContentLanguage] singleton shape — call [bind] once at app
/// boot, then subscribe to [accent] / [gender] from any widget via
/// `ValueListenableBuilder`. Persists writes through the same prefs key
/// (`prefSelectedVoice`) the rest of the app already reserves.
class AppVoicePreferences {
  AppVoicePreferences._();
  static final AppVoicePreferences instance = AppVoicePreferences._();

  final ValueNotifier<VoiceAccent> accent = ValueNotifier(VoiceAccent.us);
  final ValueNotifier<VoiceGender> gender = ValueNotifier(VoiceGender.female);

  SharedPreferences? _prefs;

  /// Reads persisted values from [prefs] and wires writes back. Call once at
  /// app boot — after the `@preResolve` `SharedPreferences` is available.
  void bind(SharedPreferences prefs) {
    _prefs = prefs;
    final stored = prefs.getString(AppConstants.prefSelectedVoice);
    final parsed = _parse(stored);
    if (parsed != null) {
      accent.value = parsed.$1;
      gender.value = parsed.$2;
    }
  }

  /// `us_male`, `us_female`, `uk_male`, `uk_female` — direct input to
  /// `CdnConfig.*Audio(id, voice)` helpers.
  String get voiceKey => '${accent.value.name}_${gender.value.name}';

  void setAccent(VoiceAccent value) {
    accent.value = value;
    _persist();
  }

  void setGender(VoiceGender value) {
    gender.value = value;
    _persist();
  }

  void _persist() {
    _prefs?.setString(AppConstants.prefSelectedVoice, voiceKey);
  }

  static (VoiceAccent, VoiceGender)? _parse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('_');
    if (parts.length != 2) return null;
    final acc = VoiceAccent.values.where((v) => v.name == parts[0]).firstOrNull;
    final gen = VoiceGender.values.where((v) => v.name == parts[1]).firstOrNull;
    if (acc == null || gen == null) return null;
    return (acc, gen);
  }
}
