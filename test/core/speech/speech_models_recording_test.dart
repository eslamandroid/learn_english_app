import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/speech/speech_models.dart';

/// Direct checks on [SpeechRecognitionUpdate]'s new `recordingPath` field.
///
/// Why not run `SpeechRecognitionService` end-to-end here? Both
/// `speech_to_text` and `record` are platform-channel plugins — their mocks
/// have to be scaffolded per platform in a widget test harness, which adds
/// a lot of noise just to prove a one-line value is forwarded. The service
/// *is* exercised in-app, and its wiring is simple enough (one assignment
/// in `_emitStopped`/`_emitFailure`) that a focused model test here plus
/// the propagation-into-attempts tests above cover the contract.
void main() {
  group('SpeechRecognitionUpdate.recordingPath', () {
    test('defaults to null when not supplied', () {
      const u = SpeechRecognitionUpdate(
        text: 'hi',
        isFinalSegment: true,
        status: SpeechStatus.stopped,
      );
      expect(u.recordingPath, isNull);
    });

    test('round-trips through constructor', () {
      const u = SpeechRecognitionUpdate(
        text: 'hi',
        isFinalSegment: true,
        status: SpeechStatus.stopped,
        recordingPath: '/tmp/take.m4a',
      );
      expect(u.recordingPath, '/tmp/take.m4a');
    });

    test('can accompany a failure update too — a user whose mic denial we '
        'surfaced might still want to hear whatever was captured', () {
      const u = SpeechRecognitionUpdate(
        text: '',
        isFinalSegment: true,
        status: SpeechStatus.failed,
        failure: SpeechFailure.permissionDenied,
        recordingPath: '/tmp/take.m4a',
      );
      expect(u.failure, SpeechFailure.permissionDenied);
      expect(u.recordingPath, '/tmp/take.m4a');
    });
  });
}
