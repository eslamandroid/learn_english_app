import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Per-platform policy for the parallel [AudioRecorder] inside
/// [SpeechRecognitionService] (TASK 12.4 §1).
///
/// Based on real-device evidence (TASK 12.3 logs on Android):
/// `record` and `speech_to_text` fight over the mic on Android — the file
/// comes back ~0.25 s long regardless of session length (`6304 bytes`,
/// `encoded 4 frames`), and the user has to speak twice before STT catches
/// anything. The `speech_to_text` package documentation also acknowledges
/// that parallel audio capture during recognition is not currently
/// supported on Android. So:
///
/// - **iOS** — recording works fine alongside STT, keep it.
/// - **Android** — never record alongside STT in release.
/// - **Other** — no need to support anywhere else.
///
/// The result is read-only at this layer; the debug toggle lives in
/// [SpeechDebugFlags] and can override the policy's default in debug
/// builds for A/B comparison.
class SpeechRecordingPolicy {
  SpeechRecordingPolicy._();

  /// Test seam: when set, [isSupported] returns the override instead of
  /// probing `Platform.*`. Reset to `null` to restore default resolution.
  static bool Function()? _override;

  /// Whether the current platform permits running the parallel recorder.
  /// Default: `Platform.isIOS` (web and everything else → false).
  static bool isSupported() {
    final o = _override;
    if (o != null) return o();
    try {
      if (kIsWeb) return false;
      return Platform.isIOS;
    } catch (_) {
      // dart:io not available (unlikely at this layer, but keeps the
      // policy total — a thrown Platform check must not take down STT).
      return false;
    }
  }

  @visibleForTesting
  static void setTestOverride(bool Function()? fn) => _override = fn;
}
