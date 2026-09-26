import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'speech_models.dart';

/// Shared, app-wide speech-to-text engine.
///
/// Any feature that needs voice input — single-word pronunciation checks,
/// full-sentence speaking practice, free-form conversation input — goes
/// through this one service instead of touching `speech_to_text` directly.
/// That keeps the plugin's quirks in one place and gives every feature the
/// same behavior for permissions, errors, and (most importantly) the
/// auto-restart logic below.
///
/// ### Why auto-restart is needed
/// On-device speech engines (Android in particular) silently end a
/// `listen()` session after a short pause or a fixed max duration, even when
/// the user is still mid-sentence. Naively surfacing that as "done" is what
/// makes STT in small apps feel like it "cuts off" — the exact complaint
/// professional apps (Google/WhatsApp-style dictation) don't have. They hide
/// it by restarting the engine transparently and stitching the transcript
/// back together. [start] with `continuous: true` does the same: when a
/// segment ends for a recoverable reason and the user hasn't stopped it, a
/// new segment starts automatically after a short debounce, and its result
/// is appended to everything heard so far.
///
/// Registered as a singleton because only one recognition session can run
/// system-wide at a time — the same reasoning as [SoundPlayer] for audio
/// playback.
@lazySingleton
class SpeechRecognitionService {
  final SpeechToText _speech;

  bool _initialized = false;
  bool _continuous = false;
  bool _userStopped = true;
  bool _finished = true;
  String _localeId = 'en_US';
  String _accumulated = '';

  /// Consecutive segments that ended with no usable result. Reset to 0 by
  /// any segment that produces a non-empty final transcript, so a long,
  /// genuinely healthy dictation session never trips this — only a broken
  /// mic/engine restarting into failure repeatedly does.
  int _consecutiveEmptyRestarts = 0;
  static const _maxConsecutiveEmptyRestarts = 3;
  static const _restartDebounce = Duration(milliseconds: 300);
  static const _maxSessionDuration = Duration(minutes: 2);

  /// On some devices the engine's `done`/`notListening` status fires up to
  /// a couple of seconds *before* the actual final `onResult` callback
  /// delivers the transcript — closing the session on the status alone
  /// discards a result that was already recognized and just hadn't arrived
  /// yet. This is how long we wait for that trailing final result before
  /// giving up and treating the segment as empty.
  static const _finalResultGrace = Duration(seconds: 3);

  Timer? _restartTimer;
  Timer? _sessionCapTimer;
  Timer? _finalResultGraceTimer;

  final _controller = StreamController<SpeechRecognitionUpdate>.broadcast();

  SpeechRecognitionService() : _speech = SpeechToText();

  /// Cumulative-transcript updates for the current session. Broadcast, so
  /// multiple widgets could observe the same session if ever needed, though
  /// in practice one bloc per active session is the norm.
  Stream<SpeechRecognitionUpdate> get updates => _controller.stream;

  bool get isListening => _speech.isListening;

  /// Starts a recognition session.
  ///
  /// - `continuous: false` (default false via [continuous] param below) is
  ///   for short, single-utterance capture — a word or short phrase, where
  ///   the first final result ends the session. Use this for pronunciation
  ///   checks.
  /// - `continuous: true` keeps listening across pauses and engine-imposed
  ///   segment limits, auto-restarting until the caller calls [stop],
  ///   producing one seamless transcript. Use this for sentence/conversation
  ///   input.
  ///
  /// Returns false immediately if the mic permission is denied or the
  /// engine can't be initialized — in both cases a final, failed update is
  /// also pushed to [updates] so a listening bloc doesn't need to check the
  /// return value separately.
  Future<bool> start({
    String localeId = 'en_US',
    bool continuous = false,
  }) async {
    if (_speech.isListening) await stop();

    _userStopped = false;
    _finished = false;
    _continuous = continuous;
    _localeId = localeId;
    _accumulated = '';
    _consecutiveEmptyRestarts = 0;

    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      _emitFailure(SpeechFailure.permissionDenied);
      return false;
    }

    if (!_initialized) {
      _initialized = await _speech.initialize(
        onError: _onEngineError,
        onStatus: _onEngineStatus,
      );
    }
    if (!_initialized) {
      _emitFailure(SpeechFailure.unavailable);
      return false;
    }

    _sessionCapTimer?.cancel();
    if (_continuous) {
      _sessionCapTimer = Timer(_maxSessionDuration, stop);
    }

    return _listenSegment();
  }

  /// Ends the session and delivers whatever was recognized as the final
  /// result. Prefer this over [cancel] whenever partial speech should still
  /// count (e.g. the user tapped the mic again to finish manually).
  Future<void> stop() async {
    _userStopped = true;
    _restartTimer?.cancel();
    _sessionCapTimer?.cancel();
    _finalResultGraceTimer?.cancel();
    if (_speech.isListening) await _speech.stop();
    _emitStopped();
  }

  /// Ends the session and discards whatever was heard — used when the
  /// caller (or bloc teardown) needs to abandon a session without treating
  /// it as an answer.
  Future<void> cancel() async {
    _userStopped = true;
    _finished = true;
    _restartTimer?.cancel();
    _sessionCapTimer?.cancel();
    _finalResultGraceTimer?.cancel();
    if (_speech.isListening) await _speech.cancel();
    _accumulated = '';
  }

  Future<bool> _listenSegment() async {
    await _speech.listen(
      onResult: _onSegmentResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: false, // handled ourselves so we can restart on it
        listenMode: _continuous ? ListenMode.dictation : ListenMode.confirmation,
        localeId: _localeId,
        pauseFor: Duration(seconds: _continuous ? 5 : 3),
        listenFor: Duration(seconds: _continuous ? 55 : 8),
      ),
    );
    return true;
  }

  void _onSegmentResult(SpeechRecognitionResult r) {
    if (_finished) return;

    final combined = _accumulated.isEmpty
        ? r.recognizedWords
        : '$_accumulated ${r.recognizedWords}'.trim();

    if (r.finalResult) {
      if (r.recognizedWords.trim().isNotEmpty) {
        _accumulated = combined;
        _consecutiveEmptyRestarts = 0;
      }
      if (!_continuous) {
        // Single-utterance capture: this final result *is* the answer.
        // Finish right here rather than waiting on the engine's status
        // callback — that callback can (and does, on some devices) fire
        // either before or after this one arrives.
        _finalResultGraceTimer?.cancel();
        _emitStopped();
        return;
      }
    }

    _controller.add(SpeechRecognitionUpdate(
      text: combined,
      isFinalSegment: false,
      status: SpeechStatus.listening,
    ));
  }

  void _onEngineStatus(String status) {
    if (status == 'listening') {
      // The mic is now genuinely armed and capturing. Arming has real
      // latency (audio focus handoff, hardware startup) — anything the
      // user says before this fires is lost before it ever reaches the
      // recognizer, not just "not recognized". Surfacing this exact
      // moment lets the UI tell the user precisely when it's safe to
      // speak, instead of them having to guess-and-wait.
      _controller.add(SpeechRecognitionUpdate(
        text: _accumulated,
        isFinalSegment: false,
        status: SpeechStatus.listening,
      ));
      return;
    }
    if (status != 'done' && status != 'notListening') return;
    if (_finished) return;
    if (_userStopped || !_continuous) {
      _awaitTrailingFinalResult();
      return;
    }
    _scheduleRestart();
  }

  void _onEngineError(SpeechRecognitionError error) {
    if (_finished) return;
    if (_userStopped || !_continuous || error.permanent) {
      _awaitTrailingFinalResult();
      return;
    }
    _scheduleRestart();
  }

  /// The engine says the session is over, but on some devices the final
  /// transcript for what was actually heard arrives a moment later via
  /// [_onSegmentResult]. Give it a short window to show up — if it does,
  /// that callback finalizes the session itself and cancels this timer; if
  /// it doesn't, fall back to finalizing with whatever was accumulated.
  void _awaitTrailingFinalResult() {
    if (_finished) return;
    _finalResultGraceTimer?.cancel();
    _finalResultGraceTimer = Timer(_finalResultGrace, () {
      if (_finished) return;
      _emitStopped();
    });
  }

  void _scheduleRestart() {
    if (_userStopped) return;

    _consecutiveEmptyRestarts++;
    if (_consecutiveEmptyRestarts > _maxConsecutiveEmptyRestarts) {
      _emitFailure(SpeechFailure.unrecoverable);
      return;
    }

    _controller.add(SpeechRecognitionUpdate(
      text: _accumulated,
      isFinalSegment: false,
      status: SpeechStatus.restarting,
    ));

    _restartTimer?.cancel();
    _restartTimer = Timer(_restartDebounce, () {
      if (_userStopped) return;
      _listenSegment();
    });
  }

  void _emitStopped() {
    _finished = true;
    _finalResultGraceTimer?.cancel();
    _controller.add(SpeechRecognitionUpdate(
      text: _accumulated,
      isFinalSegment: true,
      status: SpeechStatus.stopped,
    ));
  }

  void _emitFailure(SpeechFailure reason) {
    _userStopped = true;
    _finished = true;
    _restartTimer?.cancel();
    _sessionCapTimer?.cancel();
    _finalResultGraceTimer?.cancel();
    _controller.add(SpeechRecognitionUpdate(
      text: _accumulated,
      isFinalSegment: true,
      status: SpeechStatus.failed,
      failure: reason,
    ));
  }

  @disposeMethod
  Future<void> dispose() async {
    _restartTimer?.cancel();
    _sessionCapTimer?.cancel();
    _finalResultGraceTimer?.cancel();
    if (_speech.isListening) await _speech.cancel();
    await _controller.close();
  }
}
