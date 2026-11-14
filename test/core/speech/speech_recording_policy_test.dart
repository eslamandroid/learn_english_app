import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/speech/speech_recording_policy.dart';

/// TASK 12.4 §1 — platform policy for the parallel recorder.
void main() {
  tearDown(() => SpeechRecordingPolicy.setTestOverride(null));

  test('override returning true → isSupported=true (simulates iOS)', () {
    SpeechRecordingPolicy.setTestOverride(() => true);
    expect(SpeechRecordingPolicy.isSupported(), isTrue);
  });

  test('override returning false → isSupported=false (simulates Android)', () {
    SpeechRecordingPolicy.setTestOverride(() => false);
    expect(SpeechRecordingPolicy.isSupported(), isFalse);
  });

  test('clearing the override restores default resolution — '
      'default on this test host (not iOS) must be false', () {
    SpeechRecordingPolicy.setTestOverride(() => true);
    expect(SpeechRecordingPolicy.isSupported(), isTrue);
    SpeechRecordingPolicy.setTestOverride(null);
    // Flutter tests run on the host OS (macOS/Linux/Windows), not iOS, so
    // the default resolution must return false here. This also confirms
    // the production answer on Android (not iOS).
    expect(SpeechRecordingPolicy.isSupported(), isFalse);
  });
}
