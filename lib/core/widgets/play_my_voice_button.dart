import 'dart:io' show File;

import 'package:flutter/material.dart';

import '../../di/di.dart';
import '../theme/bayan_colors.dart';
import '../utils/audio_manager.dart';

/// Small inline "hear your own voice" replay button, shown beside the main
/// pronunciation result (✓/✗ chip, repeat-result box, etc.) across every
/// screen that uses the mic (Phonetics, Dictionary, Sentences List/Pager,
/// Conversations Chat/Pager).
///
/// Collapses to [SizedBox.shrink] when [recordingPath] is null (recorder
/// couldn't start, platform without permission, etc.) so callers can wire
/// it unconditionally without a visibility check.
///
/// Visual choice: a borderless icon, deliberately lighter than the result
/// chip next to it — this is a secondary affordance, not the primary signal
/// (TASK 12 §5).
class PlayMyVoiceButton extends StatelessWidget {
  final String? recordingPath;

  /// Icon size (default 16 — small enough to sit next to a tiny score pill
  /// without competing with it). Override on screens that want a slightly
  /// larger affordance (e.g. the sentence pager mode).
  final double size;

  /// Optional override for the audio playback entry point; defaults to the
  /// singleton [AudioManager] from [getIt]. Exists so widget tests can
  /// inject a stub without needing to configure the DI container.
  final Future<void> Function(String path)? onPlay;

  /// Optional override for the file-existence probe. Lets tests skip the
  /// filesystem round-trip without mocking `dart:io`.
  final Future<bool> Function(String path)? exists;

  const PlayMyVoiceButton({
    super.key,
    required this.recordingPath,
    this.size = 16,
    this.onPlay,
    this.exists,
  });

  @override
  Widget build(BuildContext context) {
    final path = recordingPath;
    if (path == null) return const SizedBox.shrink();
    return IconButton(
      icon: Icon(Icons.graphic_eq_rounded, size: size),
      tooltip: 'Hear what you said',
      color: BayanColors.onSurfaceVariant,
      splashRadius: size + 6,
      constraints: BoxConstraints.tightFor(width: size + 20, height: size + 20),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onPressed: () => _playSafely(context, path),
    );
  }

  /// Playback never throws out of the button. On iOS simulator (and
  /// occasionally on real devices while the mic is contested) a recording
  /// can be present but malformed; audioplayers surfaces that as a
  /// `PlatformException(DarwinAudioError, …)` which otherwise ends up as a
  /// Crashlytics event even though the app is fine. We swallow it, show a
  /// quiet SnackBar, and move on.
  Future<void> _playSafely(BuildContext context, String path) async {
    try {
      // Guard against a stale path: the file may have been pruned (cap of
      // 20 takes), removed by the OS temp-dir sweep, or never actually
      // flushed by the recorder. Playing a missing file would surface as an
      // AVFoundation error on iOS — far noisier than silently acknowledging
      // the recording is no longer around.
      final probe = exists ?? _defaultExists;
      if (!await probe(path)) {
        debugPrint('🎙️ PlayMyVoiceButton: recording file missing at $path');
        if (!context.mounted) return;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('Recording is no longer available.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      await (onPlay ?? _defaultPlay)(path);
    } catch (e, st) {
      debugPrint('🎙️ PlayMyVoiceButton playback failed: $e\n$st');
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Could not play your recording.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  static Future<void> _defaultPlay(String path) {
    return getIt<AudioManager>().playFile(path);
  }

  static Future<bool> _defaultExists(String path) => File(path).exists();
}
