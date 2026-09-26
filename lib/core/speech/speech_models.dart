/// Lifecycle status of a recognition session, decoupled from any specific
/// STT plugin so callers never need to import `speech_to_text` themselves.
enum SpeechStatus { listening, restarting, stopped, failed }

/// Reasons a session ended without producing a usable final transcript.
enum SpeechFailure {
  /// Microphone permission was denied.
  permissionDenied,

  /// The recognition engine isn't available on this device (no speech
  /// service installed, unsupported locale, etc.).
  unavailable,

  /// The engine gave up after repeated empty/erroring segments — treated as
  /// a hard failure to avoid restarting forever on a broken mic/engine.
  unrecoverable,
}

/// A single update emitted while a recognition session is active.
///
/// [text] is always the *cumulative* transcript for the whole session —
/// every finalized segment so far, plus the current partial — so consumers
/// can render it directly without stitching segments together themselves.
/// This is what makes a multi-segment (auto-restarted) session look like one
/// continuous, uninterrupted dictation to anything listening on
/// [SpeechRecognitionService.updates].
class SpeechRecognitionUpdate {
  final String text;

  /// True once for the update that ends the session (user stopped it, a
  /// hard timeout was hit, or it failed). No further updates follow.
  final bool isFinalSegment;

  final SpeechStatus status;

  /// Set only when [status] is [SpeechStatus.failed].
  final SpeechFailure? failure;

  const SpeechRecognitionUpdate({
    required this.text,
    required this.isFinalSegment,
    required this.status,
    this.failure,
  });
}
