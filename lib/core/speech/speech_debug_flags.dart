import 'package:flutter/foundation.dart';

import 'speech_recording_policy.dart';

/// Debug-only, mutable toggles for diagnosing speech recognition on real
/// devices (TASK 12.3). All defaults match production behaviour; flipping
/// a flag at runtime only has effect in `kDebugMode` builds — the Settings
/// screen hides the toggle UI in release so the state can't drift there.
///
/// Kept in `core/` rather than inside the service so test code (and the
/// settings widget) can read / mutate flags without reaching into service
/// internals.
class SpeechDebugFlags {
  SpeechDebugFlags._();

  /// Default seeded from [SpeechRecordingPolicy.isSupported] (TASK 12.4 §1):
  /// `true` on iOS, `false` on Android and elsewhere. The debug Settings
  /// toggle flips this, which is the only way to enable the parallel
  /// recorder on Android (and only in debug builds — the toggle UI is
  /// gated behind `kDebugMode`).
  ///
  /// Service behaviour is a two-gate decision (policy AND flag) so release
  /// Android stays off even if a test accidentally leaves this `true`.
  static final ValueNotifier<bool> parallelRecording =
      ValueNotifier<bool>(SpeechRecordingPolicy.isSupported());
}
