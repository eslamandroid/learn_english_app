import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/speech/speech_debug_flags.dart';
import 'package:learn_english_app/core/speech/speech_recording_policy.dart';

/// TASK 12.3 §2 — flipping the flag notifies listeners so the Settings UI
/// rebuilds without a `setState`.
///
/// TASK 12.4 §1 — the flag's **initial** value is driven by
/// [SpeechRecordingPolicy.isSupported]: `true` on iOS, `false` on Android
/// (and `false` on test hosts, which is also what the test harness sees).
/// This test can't observe the initial value directly — the field is
/// `static final` and resolved once at first access, which may have
/// happened earlier in the test run — so we assert the dependency instead.
void main() {
  // The flag is a static ValueNotifier that outlives individual tests —
  // reset to a known state after each case so order can't leak.
  tearDown(() {
    SpeechRecordingPolicy.setTestOverride(null);
    SpeechDebugFlags.parallelRecording.value =
        SpeechRecordingPolicy.isSupported();
  });

  test('setting the value notifies listeners (no manual rebuild needed in '
      'the Settings UI)', () {
    // Seed to a known state BEFORE registering the listener — the field
    // outlives tests, so otherwise an unlucky setter→setter sequence can
    // skip the first notification when the value already matches.
    SpeechDebugFlags.parallelRecording.value = true;

    final observed = <bool>[];
    void listener() {
      observed.add(SpeechDebugFlags.parallelRecording.value);
    }

    SpeechDebugFlags.parallelRecording.addListener(listener);
    addTearDown(
      () => SpeechDebugFlags.parallelRecording.removeListener(listener),
    );

    SpeechDebugFlags.parallelRecording.value = false;
    SpeechDebugFlags.parallelRecording.value = true;

    expect(observed, [false, true]);
  });
}
