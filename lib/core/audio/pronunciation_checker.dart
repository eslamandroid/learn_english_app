import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Outcome of a single pronunciation attempt.
enum PronunciationOutcome { correct, incorrect, noSpeech, denied, unavailable }

class PronunciationResult {
  final PronunciationOutcome outcome;
  final String heard;

  const PronunciationResult(this.outcome, this.heard);

  bool get isCorrect => outcome == PronunciationOutcome.correct;
}

/// Thin singleton around [SpeechToText] for short, one-word pronunciation
/// checks. Only one recognition session runs at a time. Not registered with DI
/// to avoid codegen — access via [PronunciationChecker.instance].
class PronunciationChecker {
  PronunciationChecker._();
  static final PronunciationChecker instance = PronunciationChecker._();

  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  void Function(String partial)? _onPartial;
  VoidCallback? _onDone;

  bool get isListening => _speech.isListening;

  Future<bool> _ensureInit() async {
    if (_initialized) return true;

    final mic = await Permission.microphone.request();
    if (!mic.isGranted) return false;

    _initialized = await _speech.initialize(
      onError: (_) => _onDone?.call(),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _onDone?.call();
        }
      },
    );
    return _initialized;
  }

  /// Starts listening. [onPartial] streams interim transcripts; [onDone] fires
  /// when recognition ends (final result, timeout, or error). Returns false if
  /// the mic permission was denied or the engine is unavailable.
  Future<bool> start({
    required void Function(String partial) onPartial,
    required VoidCallback onDone,
    String localeId = 'en_US',
  }) async {
    final ok = await _ensureInit();
    if (!ok) return false;

    _onPartial = onPartial;
    _onDone = onDone;

    await _speech.listen(
      onResult: (SpeechRecognitionResult r) =>
          _onPartial?.call(r.recognizedWords),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
        localeId: localeId,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 8),
      ),
    );
    return true;
  }

  Future<void> stop() async {
    if (_speech.isListening) await _speech.stop();
  }

  /// Compares [heard] against [target], tolerant of casing/punctuation and
  /// multi-word transcripts.
  static bool matches(String heard, String target) {
    String norm(String s) =>
        s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').trim();

    final h = norm(heard);
    final t = norm(target);
    if (t.isEmpty || h.isEmpty) return false;
    if (h == t) return true;
    final words = h.split(RegExp(r'\s+'));
    return words.contains(t) || h.contains(t);
  }
}
