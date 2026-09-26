import 'package:audioplayers/audioplayers.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AudioManager {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Stream<Duration> get positionStream => _player.onPositionChanged;
  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;
  Stream<Duration> get durationStream => _player.onDurationChanged;
  Stream<void> get completionStream => _player.onPlayerComplete;

  Future<void> play(String url, {double rate = 1.0}) async {
    await _player.stop();
    await _player.play(UrlSource(url));
    await _applyRate(rate);
  }

  /// Plays a local file. Pass [mimeType] (e.g. `audio/mpeg`) so iOS can pick
  /// the right reader when the file extension is ambiguous. [rate] scales
  /// playback speed (1.0 = normal, 0.5 = half speed).
  Future<void> playFile(
    String path, {
    String? mimeType,
    double rate = 1.0,
  }) async {
    await _player.stop();
    await _player.play(DeviceFileSource(path, mimeType: mimeType));
    await _applyRate(rate);
  }

  /// Plays a bundled asset. [assetPath] is relative to the `assets/` root,
  /// e.g. `sounds/consonants_k.m4a`. Use AAC/m4a (not ogg) — iOS/AVFoundation
  /// cannot decode OGG Vorbis.
  Future<void> playAsset(String assetPath, {double rate = 1.0}) async {
    await _player.stop();
    await _player.play(AssetSource(assetPath));
    await _applyRate(rate);
  }

  Future<void> playFromPosition(String url, Duration position) async {
    await _player.stop();
    await _player.play(UrlSource(url), position: position);
  }

  /// Applied after every play() call so a Slow-then-Normal sequence always
  /// resets the player's rate — otherwise Android carries the last rate over
  /// to the next playback.
  Future<void> _applyRate(double rate) => _player.setPlaybackRate(rate);

  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.resume();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);

  @disposeMethod
  Future<void> close() => _player.dispose();
}
