import 'dart:async';
import 'dart:io' show Directory, File;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:audioplayers/audioplayers.dart';

import 'speech_debug_flags.dart';
import 'speech_models.dart';
import 'speech_recording_policy.dart';

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

  /// Parallel-session recorder used only to capture the user's take so they
  /// can replay it ("hear your own voice") beside the practice result. Lazy-
  /// initialised the first time a session starts so unit tests that only
  /// touch STT don't force the plugin to load. Failures here are swallowed —
  /// the STT session must continue unaffected (TASK 12 §3).
  AudioRecorder? _recorder;
  String? _recordingPath;

  /// Per-session recording cache. Each `start()` writes a NEW file under this
  /// directory — a shared fixed filename made replay unreliable when a bloc
  /// stored one `recordingPath` per item in a Map (sentence A's entry would
  /// end up pointing at sentence B's audio after the second take, TASK 12.1
  /// §1). Files are capped by [_maxTakes] with the oldest pruned on each
  /// `start()` so the folder never grows unbounded.
  Directory? _takesDir;
  int _takeCounter = 0;

  /// Hard cap on how many pending take files we keep in [_takesDir]. The oldest
  /// is pruned when a new session would exceed this. 20 is enough to let the
  /// user revisit several recent attempts across the current screen without
  /// risking disk pressure.
  static const int _maxTakes = 20;

  /// How long we wait for the recorder plugin to confirm it has flushed and
  /// closed the file before giving up and discarding the path. On a healthy
  /// stop this returns in a few tens of ms; the 1 s bound exists to protect
  /// the UI from the rare case where the audio session hangs mid-release
  /// (seen on iOS once the mic was contested). On timeout we drop the path
  /// so the replay button never points at a potentially half-written file.
  static const _recorderStopTimeout = Duration(seconds: 1);

  bool _initialized = false;
  bool _continuous = false;
  bool _userStopped = true;
  bool _finished = true;
  String _localeId = 'en_US';
  String _accumulated = '';

  /// Latest *cumulative* partial transcript (`_accumulated` + current
  /// segment partial). Kept so a manual stop that beats the engine's final
  /// callback doesn't throw away everything the user said — [_emitStopped]
  /// falls back to this when [_accumulated] is still empty. Reset in [start]
  /// along with [_accumulated] (TASK 12.2 §A).
  String _lastPartial = '';

  /// Single-emission gate for the final update: both [_emitStopped] and
  /// [_emitFailure] honour it, so a race between (a) a trailing final result
  /// landing after the user tapped stop, (b) the grace timer firing, and (c)
  /// an engine error arriving simultaneously can only ever emit once.
  bool _emitted = false;

  /// Consecutive segments that ended with no usable result. Reset to 0 by
  /// any segment that produces a non-empty final transcript, so a long,
  /// genuinely healthy dictation session never trips this — only a broken
  /// mic/engine restarting into failure repeatedly does.
  int _consecutiveEmptyRestarts = 0;
  static const _maxConsecutiveEmptyRestarts = 3;
  static const _restartDebounce = Duration(milliseconds: 300);
  /// Hard cap on a continuous session. Conversation lines are a few seconds
  /// long and the practice bloc auto-stops once the transcript settles, so
  /// anything still open at 45 s is a forgotten mic, not a learner mid-line.
  static const _maxSessionDuration = Duration(seconds: 45);

  /// On some devices the engine's `done`/`notListening` status fires up to
  /// a couple of seconds *before* the actual final `onResult` callback
  /// delivers the transcript — closing the session on the status alone
  /// discards a result that was already recognized and just hadn't arrived
  /// yet. This is how long we wait for that trailing final result before
  /// giving up and treating the segment as empty.
  static const _finalResultGrace = Duration(seconds: 3);

  /// Shorter wait used specifically when the user tapped stop manually.
  /// Android's SpeechRecognizer typically delivers its final result within
  /// a few hundred ms of `stop()` being called; 1.5 s is long enough to
  /// catch that trailing transcript without leaving the UI visibly hanging.
  /// Documented in TASK 12.2 §A.
  static const _manualStopGrace = Duration(milliseconds: 1500);

  Timer? _restartTimer;
  Timer? _sessionCapTimer;
  Timer? _finalResultGraceTimer;

  /// Peak dBFS seen on the recorder's amplitude stream during this session.
  /// Starts at a floor well below the microphone noise floor so the first
  /// genuine sample always wins. On stop, if STT heard the user but we saw
  /// no audible peak, we treat the recording as a silent-capture bug and
  /// drop the path (TASK 12.2 §C.3) — a silent replay button is worse than
  /// no button.
  double _peakDbfs = _dbfsFloor;
  StreamSubscription<Amplitude>? _amplitudeSub;

  /// dBFS value that counts as "clearly silent". Picked at the loud end of
  /// the typical room-noise-only range so the safety net doesn't fire on a
  /// genuinely quiet speaker. If false negatives show up on real devices,
  /// tune via measurement rather than guesswork.
  static const double _silentPeakThresholdDbfs = -45;

  /// Floor seeded into [_peakDbfs] at session start. -160 is below any real
  /// capture value and comfortably below the plugin's own `-∞` sentinel on
  /// Android (which it emits as a very large negative number).
  static const double _dbfsFloor = -160;

  /// Session-local min/max of the STT engine's own sound-level stream.
  /// Logged as one summary line at session end (TASK 12.3 §1) so a stuck
  /// recognizer that stayed near the floor during the user's speech is
  /// visibly distinguishable from one that heard the full range.
  double _minSoundLevel = double.infinity;
  double _maxSoundLevel = double.negativeInfinity;

  /// Wall-clock reference used by [_log] to prefix every diagnostic line
  /// with `+<ms since session start>`. Reset in [start]; stays null before
  /// the first session so a stray log before start is still readable.
  DateTime? _sessionStartedAt;

  final _controller = StreamController<SpeechRecognitionUpdate>.broadcast();

  SpeechRecognitionService() : _speech = SpeechToText();

  /// Test-only constructor that lets a mock [SpeechToText] be injected
  /// without rewiring the DI container (TASK 12.2 §Tests). Production uses
  /// the default constructor above, which creates the real engine.
  @visibleForTesting
  SpeechRecognitionService.withSpeech(this._speech);

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

    // Cancel any grace-timer the previous session may have armed — otherwise
    // it fires 1.5 s later with this (new) session's cleared state and
    // emits a bogus "stopped" update over the live run (TASK 12.2 §A).
    _finalResultGraceTimer?.cancel();

    _userStopped = false;
    _finished = false;
    _emitted = false;
    _continuous = continuous;
    _localeId = localeId;
    _accumulated = '';
    _lastPartial = '';
    _consecutiveEmptyRestarts = 0;
    _recordingPath = null;
    _peakDbfs = _dbfsFloor;
    _minSoundLevel = double.infinity;
    _maxSoundLevel = double.negativeInfinity;
    _sessionStartedAt = DateTime.now();
    _log('session start: locale=$localeId continuous=$continuous '
        'parallelRecording=${SpeechDebugFlags.parallelRecording.value}');

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

    // Start the parallel recording AFTER STT has initialised but BEFORE
    // listen() — if STT ever ends up blocking the mic exclusively on some
    // device, the recorder's hasPermission()/start() call surfaces that
    // non-fatally before STT actually arms. Either way, nothing here is
    // allowed to throw up the stack.
    await _startRecording();

    return _listenSegment();
  }

  Future<void> _startRecording() async {
    // Platform policy is the authoritative gate (TASK 12.4 §1). The debug
    // flag can override on Android *only in debug builds* — release
    // Android never records regardless of the flag's state, because the
    // Settings toggle is gated behind `kDebugMode`. On iOS the flag's
    // default is `true` (policy-aligned) so production is untouched.
    final policyAllows = SpeechRecordingPolicy.isSupported();
    final flagAllows = SpeechDebugFlags.parallelRecording.value;
    if (!policyAllows && !flagAllows) {
      // Release-Android steady state.
      _log('🎙️ recording blocked (policy=false, flag=false) → skipping');
      return;
    }
    if (!flagAllows) {
      // Policy says yes but the dev toggle was flipped off — honour it so
      // the debug A/B comparison works on iOS too.
      _log('🎙️ recording disabled by debug flag → skipping');
      return;
    }
    try {
      _recorder ??= AudioRecorder();
      final granted = await _recorder!.hasPermission();
      _log('🎙️ recorder hasPermission=$granted');
      if (!granted) {
        debugPrint('🎙️ recorder permission denied — replay disabled');
        return;
      }
      final dir = await _ensureTakesDir();
      await pruneTakes(dir, keep: _maxTakes - 1);
      final path = nextTakePath(dir, counter: ++_takeCounter);
      await _recorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          numChannels: 1,
          sampleRate: 16000,
        ),
        path: path,
      );
      _recordingPath = path;
      _log('🎙️ recorder started at $path');
      _subscribeAmplitude();
    } catch (e) {
      // Non-fatal: STT must keep working.
      debugPrint('🎙️ recorder start failed (non-fatal): $e');
      _log('🎙️ recorder start FAILED (non-fatal): $e');
      _recordingPath = null;
    }
  }

  /// Debug diagnostic line. Prefixed with `[stt +<ms from session start>]`
  /// so cross-callback traces (status / result / recorder) line up on the
  /// same timeline (TASK 12.3 §1). Compiled out in release — `kDebugMode`
  /// is a const in release builds so the branch body is tree-shaken.
  void _log(String message) {
    if (!kDebugMode) return;
    final start = _sessionStartedAt;
    final ms = start == null
        ? '----'
        : DateTime.now().difference(start).inMilliseconds.toString().padLeft(4);
    debugPrint('[stt +${ms}ms] $message');
  }

  void _subscribeAmplitude() {
    _amplitudeSub?.cancel();
    final rec = _recorder;
    if (rec == null) return;
    try {
      _amplitudeSub = rec
          .onAmplitudeChanged(const Duration(milliseconds: 150))
          .listen(
            (amp) {
              final v = amp.current;
              // Some drivers emit `-∞` or NaN as a quiet-mic sentinel —
              // isFinite filters both without needing to import math.
              if (v.isFinite && v > _peakDbfs) _peakDbfs = v;
            },
            onError: (Object e) {
              debugPrint('🎙️ amplitude stream error (non-fatal): $e');
            },
          );
    } catch (e) {
      // onAmplitudeChanged can throw if the platform isn't ready — this is
      // only the safety net, STT must proceed regardless.
      debugPrint('🎙️ amplitude subscription failed (non-fatal): $e');
    }
  }

  Future<Directory> _ensureTakesDir() async {
    final cached = _takesDir;
    if (cached != null) return cached;
    final tempDir = await getTemporaryDirectory();
    final dir = Directory(p.join(tempDir.path, 'practice_takes'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _takesDir = dir;
    return dir;
  }

  Future<String?> _stopRecording() async {
    final rec = _recorder;
    // Always release the amplitude subscription, even if there's no recorder
    // (unusual, but keeps the stream from leaking across sessions).
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    if (rec == null) return _recordingPath;
    var timedOut = false;
    String? returnedPath;
    try {
      if (await rec.isRecording()) {
        returnedPath = await rec.stop().timeout(
          _recorderStopTimeout,
          onTimeout: () {
            timedOut = true;
            return null;
          },
        );
      }
    } catch (e) {
      debugPrint('🎙️ recorder stop failed (non-fatal): $e');
      _recordingPath = null;
      return null;
    }
    if (timedOut) {
      // The plugin didn't confirm the file was flushed within the bound.
      // Attach no path rather than a potentially truncated take — a missing
      // replay is far less bad than one that crashes AVFoundation on load.
      debugPrint('🎙️ recorder stop timed out — dropping path');
      _recordingPath = null;
      return null;
    }
    // record.stop returns the final path on success (sometimes differs from
    // the one we handed in on web). Prefer it when present.
    if (returnedPath != null) _recordingPath = returnedPath;
    // Guard against the known-nasty case: on iOS simulator (and sometimes on
    // real devices while STT holds the mic exclusively) `record` reports
    // success but writes a zero-byte or malformed file. Playing that back
    // throws AVPlayerItem.Status.failed inside audioplayers and surfaces as
    // a Crashlytics event. Clearing `_recordingPath` here means the
    // PlayMyVoiceButton collapses to SizedBox.shrink and nothing downstream
    // ever tries to play a broken file.
    await _validateRecordingOrClear();
    final preDropPath = _recordingPath;
    final preDropSize = preDropPath == null
        ? null
        : await _safeFileLength(preDropPath);
    _recordingPath = await dropPathIfSilent(
      path: _recordingPath,
      peakDbfs: _peakDbfs,
    );
    // Duration check only runs if silence didn't already clear the path.
    final sessionStart = _sessionStartedAt;
    if (_recordingPath != null && sessionStart != null) {
      _recordingPath = await dropPathIfTooShort(
        path: _recordingPath,
        sessionDuration: DateTime.now().difference(sessionStart),
        measure: _durationMeasurer ?? _measureAudioDuration,
      );
    }
    _log('🎙️ recorder stop: peakDbfs=${_peakDbfs.toStringAsFixed(1)} '
        'size=${preDropSize ?? "n/a"}B path=${preDropPath ?? "null"} '
        'kept=${_recordingPath != null}');
    return _recordingPath;
  }

  /// Loads the file through a throwaway [AudioPlayer] purely to read its
  /// duration metadata, then disposes immediately. Any failure returns
  /// `null` so the duration safety net defaults to "keep" rather than
  /// dropping a usable take on a measurement glitch.
  static Future<Duration?> _measureAudioDuration(String path) async {
    final player = AudioPlayer();
    try {
      await player.setSource(DeviceFileSource(path));
      return await player.getDuration();
    } catch (_) {
      return null;
    } finally {
      try {
        await player.dispose();
      } catch (_) {}
    }
  }

  /// Test seam: swap in a synchronous stub so the duration safety net
  /// can be exercised without routing through the audioplayers plugin.
  Future<Duration?> Function(String path)? _durationMeasurer;

  @visibleForTesting
  // ignore: use_setters_to_change_properties
  void setDurationMeasurerForTest(
    Future<Duration?> Function(String path)? fn,
  ) =>
      _durationMeasurer = fn;

  Future<int?> _safeFileLength(String path) async {
    try {
      final f = File(path);
      if (!await f.exists()) return null;
      return await f.length();
    } catch (_) {
      return null;
    }
  }

  /// Silence safety net (TASK 12.2 §C.3, revised by TASK 12.4 §3).
  ///
  /// Returns the path to attach, or `null` if the capture peak sat at or
  /// below [threshold] — in that case the file is also deleted so a prune
  /// doesn't have to catch it later.
  ///
  /// We no longer require STT to have produced a transcript (as 12.2 did):
  /// Islam's call on 2026-10-06 was that a silent recording offers zero
  /// value to replay regardless of outcome, including the "Didn't catch
  /// that" case — a button that plays silence is worse than no button.
  @visibleForTesting
  static Future<String?> dropPathIfSilent({
    required String? path,
    required double peakDbfs,
    double threshold = _silentPeakThresholdDbfs,
  }) async {
    if (path == null) return null;
    if (peakDbfs > threshold) return path;
    debugPrint('🎙️ take peak ${peakDbfs.toStringAsFixed(1)} dBFS <= '
        '$threshold — treating as silent capture, dropping path.');
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
    return null;
  }

  /// Duration safety net (TASK 12.4 §2). The silence net misses one failure
  /// mode: a file that's loud but short — i.e. the recorder captured a
  /// quarter-second of the user's start before STT took the mic away. The
  /// bytes look normal; peak dBFS is fine; but the replay is useless.
  ///
  /// Rule: if the session ran for at least [minSessionForCheck] and the
  /// file's measured duration is below [minRatio] of the wall-clock
  /// session length, drop the path and delete the file. Any measurement
  /// failure keeps the path (we only act on positive evidence).
  @visibleForTesting
  static Future<String?> dropPathIfTooShort({
    required String? path,
    required Duration sessionDuration,
    required Future<Duration?> Function(String path) measure,
    Duration minSessionForCheck = _minSessionForDurationCheck,
    double minRatio = _minDurationRatio,
  }) async {
    if (path == null) return null;
    if (sessionDuration < minSessionForCheck) return path;
    Duration? fileDuration;
    try {
      fileDuration = await measure(path);
    } catch (_) {
      return path;
    }
    if (fileDuration == null) return path;
    final sessionMs = sessionDuration.inMilliseconds;
    if (sessionMs == 0) return path;
    final ratio = fileDuration.inMilliseconds / sessionMs;
    if (ratio >= minRatio) return path;
    debugPrint('🎙️ take duration ${fileDuration.inMilliseconds}ms vs '
        'session ${sessionMs}ms (ratio=${ratio.toStringAsFixed(2)} < '
        '$minRatio) — dropping path.');
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
    return null;
  }

  /// Minimum session wall-clock length before the duration ratio is
  /// checked. A one-second mic tap can legitimately produce a short file;
  /// anything longer than this is where "file is a tiny fraction of the
  /// session" starts to indicate the Android mic-contention bug.
  static const Duration _minSessionForDurationCheck =
      Duration(milliseconds: 1500);

  /// Minimum fraction of the session wall-clock the recording should cover
  /// to be considered valid. 60% leaves room for the ~200 ms arming delay
  /// at the start and a graceful stop fade at the end without flagging a
  /// real capture as truncated.
  static const double _minDurationRatio = 0.6;

  /// Builds the next take filename under [dir]. The microsecond timestamp
  /// alone is not reliable (Dart's `DateTime.now()` only advances at
  /// millisecond resolution on Windows, and two rapid-fire sessions in a
  /// test can collide), so an incrementing counter is appended too.
  @visibleForTesting
  static String nextTakePath(
    Directory dir, {
    required int counter,
    DateTime? now,
  }) {
    final ts = (now ?? DateTime.now()).microsecondsSinceEpoch;
    return p.join(dir.path, 'take_${ts}_$counter.m4a');
  }

  /// Keeps at most [keep] most-recently-modified files in [dir]. Deletes the
  /// rest. Any I/O error is logged and swallowed — pruning is best-effort
  /// cleanup, never allowed to abort a recording session.
  @visibleForTesting
  static Future<void> pruneTakes(Directory dir, {required int keep}) async {
    try {
      if (!await dir.exists()) return;
      final files = <File>[];
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is File) files.add(entity);
      }
      if (files.length <= keep) return;
      files.sort((a, b) {
        final sa = a.statSync().modified;
        final sb = b.statSync().modified;
        return sa.compareTo(sb);
      });
      final victims = files.take(files.length - keep);
      for (final f in victims) {
        try {
          await f.delete();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('🎙️ take prune failed (non-fatal): $e');
    }
  }

  /// Minimum bytes a usable AAC-LC recording should produce — enough to
  /// cover the header + a few audio frames. Anything shorter is almost
  /// certainly an empty/aborted capture that AVFoundation can't decode.
  static const int _minRecordingBytes = 1024;

  Future<void> _validateRecordingOrClear() async {
    final path = _recordingPath;
    if (path == null) return;
    try {
      final file = File(path);
      if (!await file.exists()) {
        debugPrint('🎙️ recording file does not exist — clearing path.');
        _recordingPath = null;
        return;
      }
      final size = await file.length();
      if (size < _minRecordingBytes) {
        debugPrint('🎙️ recording file too small ($size bytes) — clearing.');
        _recordingPath = null;
      }
    } catch (e) {
      debugPrint('🎙️ recording validation failed (non-fatal): $e');
      _recordingPath = null;
    }
  }

  /// Ends the session and delivers whatever was recognized as the final
  /// result. Prefer this over [cancel] whenever partial speech should still
  /// count (e.g. the user tapped the mic again to finish manually).
  ///
  /// We deliberately do NOT emit here. On Android the real final transcript
  /// lands via `onResult(finalResult: true)` a few hundred ms *after*
  /// `_speech.stop()` returns — emitting immediately with whatever's
  /// accumulated so far would race past that callback and surface
  /// "Didn't catch that" even when the user spoke a full sentence. Instead
  /// we arm a short grace timer; whichever event arrives first (the
  /// trailing final result or the timeout) does the emission (TASK 12.2 §A).
  Future<void> stop() async {
    _userStopped = true;
    _restartTimer?.cancel();
    _sessionCapTimer?.cancel();
    if (_finished || _emitted) return;
    _finalResultGraceTimer?.cancel();
    if (_speech.isListening) await _speech.stop();
    _awaitTrailingFinalResult(grace: _manualStopGrace);
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
      // Sound-level values are plugin-dependent (Android often 0..10,
      // iOS -2..10). We only track min/max for a diagnostic summary at
      // session end (TASK 12.3 §1) — the exact scale doesn't matter for
      // "did it move during speech or stay flat?".
      onSoundLevelChange: _onSoundLevel,
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

  void _onSoundLevel(double level) {
    if (level < _minSoundLevel) _minSoundLevel = level;
    if (level > _maxSoundLevel) _maxSoundLevel = level;
  }

  void _onSegmentResult(SpeechRecognitionResult r) {
    if (_finished) return;

    _log('onResult final=${r.finalResult} '
        'words=${r.recognizedWords.trim().split(RegExp(r"\s+")).where((w) => w.isNotEmpty).length} '
        'confidence=${r.confidence.toStringAsFixed(2)} '
        'text="${r.recognizedWords}"');

    final combined = _accumulated.isEmpty
        ? r.recognizedWords
        : '$_accumulated ${r.recognizedWords}'.trim();

    if (!r.finalResult) {
      // Keep the rolling partial — the manual-stop grace path (TASK 12.2 §A)
      // falls back to this if no final result ever lands, so a user who
      // tapped stop mid-sentence still gets whatever the engine had already
      // recognized rather than an empty "Didn't catch that".
      _lastPartial = combined;
    }

    if (r.finalResult) {
      if (r.recognizedWords.trim().isNotEmpty) {
        _accumulated = combined;
        _consecutiveEmptyRestarts = 0;
      }
      // Single-utterance captures end on this final by design, and a
      // manual stop in continuous mode should also end immediately once
      // the engine's trailing final arrives — further restart would just
      // discard the transcript the user asked us to keep (TASK 12.2 §A).
      if (!_continuous || _userStopped) {
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
    _log('onStatus=$status');
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
    // Highest-signal line in the trace (TASK 12.3 §1):
    //   error_audio / error_busy / error_client → mic contention
    //   error_no_match / error_speech_timeout   → recognizer heard silence
    _log('onError msg=${error.errorMsg} permanent=${error.permanent}');
    if (_finished) return;
    if (_userStopped || !_continuous || error.permanent) {
      _awaitTrailingFinalResult();
      return;
    }
    _scheduleRestart();
  }

  /// The engine says the session is over (or the user tapped stop), but on
  /// some devices the final transcript for what was actually heard arrives
  /// a moment later via [_onSegmentResult]. Give it a short window to show
  /// up — if it does, that callback finalizes the session itself and
  /// cancels this timer; if it doesn't, fall back to finalizing with
  /// whatever was accumulated.
  ///
  /// [grace] overrides the default engine-side wait with a shorter one for
  /// manual stops (TASK 12.2 §A), where the engine is already draining and
  /// the UI should feel snappy.
  void _awaitTrailingFinalResult({Duration? grace}) {
    if (_finished) return;
    _finalResultGraceTimer?.cancel();
    _finalResultGraceTimer = Timer(grace ?? _finalResultGrace, () {
      if (_finished) return;
      _emitStopped();
    });
  }

  void _scheduleRestart() {
    if (_userStopped) return;

    // A segment can end (status `done`, or error_speech_timeout) without
    // the engine ever delivering a final result for what it had already
    // recognized as partials. Those words are real speech — promote the
    // rolling partial into the committed transcript so the restart appends
    // to it instead of silently dropping the tail of the user's sentence.
    if (_lastPartial.length > _accumulated.length) {
      _accumulated = _lastPartial;
      _consecutiveEmptyRestarts = 0;
    }

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

  /// Awaits the recorder stop (which also validates the file size) so the
  /// path we attach to the final update is already validated. Previously
  /// this used `unawaited(_stopRecording())` and read `_recordingPath`
  /// synchronously — on iOS simulator that routinely attached a stale
  /// path to a zero-byte file, blowing up AVFoundation on replay.
  ///
  /// Guarded by [_emitted] so overlapping sources — a trailing final
  /// result and the manual-stop grace timer firing in the same tick, or an
  /// engine `done` status landing after the user tapped stop — can only
  /// ever surface one terminal update (TASK 12.2 §A).
  Future<void> _emitStopped() async {
    if (_emitted) return;
    _emitted = true;
    _finished = true;
    _finalResultGraceTimer?.cancel();
    _logSoundLevelSummary();
    await _stopRecording();
    // Text precedence: a committed final transcript wins; otherwise fall
    // back to the last rolling partial (manual-stop case where the engine
    // never got to emit its final). An empty string is still a valid
    // outcome — downstream treats it as noSpeech.
    final text = _accumulated.isNotEmpty ? _accumulated : _lastPartial;
    _log('emitStopped text="$text" recordingPath=${_recordingPath ?? "null"}');
    _controller.add(SpeechRecognitionUpdate(
      text: text,
      isFinalSegment: true,
      status: SpeechStatus.stopped,
      recordingPath: _recordingPath,
    ));
  }

  Future<void> _emitFailure(SpeechFailure reason) async {
    if (_emitted) return;
    _emitted = true;
    _userStopped = true;
    _finished = true;
    _restartTimer?.cancel();
    _sessionCapTimer?.cancel();
    _finalResultGraceTimer?.cancel();
    _logSoundLevelSummary();
    await _stopRecording();
    _log('emitFailure reason=$reason text="$_accumulated"');
    _controller.add(SpeechRecognitionUpdate(
      text: _accumulated,
      isFinalSegment: true,
      status: SpeechStatus.failed,
      failure: reason,
      recordingPath: _recordingPath,
    ));
  }

  void _logSoundLevelSummary() {
    if (!kDebugMode) return;
    // If no samples ever came through (engine never fired), say so plainly
    // rather than printing +inf/-inf.
    if (!_minSoundLevel.isFinite || !_maxSoundLevel.isFinite) {
      _log('soundLevel summary: no samples received');
      return;
    }
    _log('soundLevel summary: min=${_minSoundLevel.toStringAsFixed(2)} '
        'max=${_maxSoundLevel.toStringAsFixed(2)}');
  }

  @disposeMethod
  Future<void> dispose() async {
    _restartTimer?.cancel();
    _sessionCapTimer?.cancel();
    _finalResultGraceTimer?.cancel();
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    if (_speech.isListening) await _speech.cancel();
    await _stopRecording();
    // Clean up the entire takes directory — all cached recordings are
    // ephemeral by design (TASK 12.1 §A), so there's no risk of discarding
    // something the user wanted to keep.
    final dir = _takesDir;
    if (dir != null) {
      try {
        if (await dir.exists()) await dir.delete(recursive: true);
      } catch (_) {}
    }
    try {
      await _recorder?.dispose();
    } catch (_) {}
    await _controller.close();
  }
}
