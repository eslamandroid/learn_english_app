import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';

import '../utils/audio_manager.dart';
import 'sound_cache.dart';

/// Result of a play attempt — useful for telemetry / debugging.
enum SoundSource { cache, cdn, deviceTts, googleTts, asset }

/// Unified sound playback with a 4-tier fallback chain:
///
/// 1. **Cache hit** — play the local file (instant, offline)
/// 2. **CDN download** — fetch from CloudFront, cache, play
/// 3. **Device TTS** — speak via the on-device engine (`flutter_tts`)
/// 4. **Google TTS** — last-resort HTTP fetch from translate-tts, cache, play
///
/// CDN bytes and Google-TTS bytes are both played through [AudioManager], so
/// the player UI's position / duration streams keep working uniformly.
/// Device TTS plays through the system audio engine and emits its own
/// completion signal — listen on [completionStream] for a unified end-of-play
/// notification.
@lazySingleton
class SoundPlayer {
  final AudioManager _audioManager;
  final SoundCache _cache;
  final FlutterTts _tts;
  final Dio _dio;

  final _completionController = StreamController<SoundSource>.broadcast();
  StreamSubscription<void>? _audioCompletionSub;
  SoundSource? _currentSource;

  SoundPlayer(this._audioManager, this._cache)
      : _tts = FlutterTts(),
        _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 15),
        )) {
    _audioCompletionSub = _audioManager.completionStream.listen((_) {
      final src = _currentSource;
      if (src != null) {
        debugPrint('🔊 TTS.complete source=$src');
        _currentSource = null;
        _completionController.add(src);
      }
    });

    _tts.setCompletionHandler(() {
      if (_currentSource == SoundSource.deviceTts) {
        debugPrint('🔊 TTS.deviceTts complete');
        _currentSource = null;
        _completionController.add(SoundSource.deviceTts);
      }
    });
    _tts.setErrorHandler((msg) {
      if (_currentSource == SoundSource.deviceTts) {
        debugPrint('🔊 TTS.deviceTts error msg=$msg');
        _currentSource = null;
        _completionController.add(SoundSource.deviceTts);
      }
    });
  }

  AudioManager get audioManager => _audioManager;

  Stream<SoundSource> get completionStream => _completionController.stream;

  /// True when a TTS utterance is in flight (audioplayers streams are silent
  /// in this case — the player UI should treat it as "playing, no progress").
  bool get isTtsActive => _currentSource == SoundSource.deviceTts;

  /// Plays the sound for [cdnUrl] using the 4-tier fallback chain.
  ///
  /// [fallbackText] is what device / Google TTS will speak if the CDN file is
  /// missing. [locale] is a BCP-47 tag (`en-US`, `en-GB`, …) used by both TTS
  /// engines.
  Future<SoundSource> play({
    required String cdnUrl,
    required String fallbackText,
    String locale = 'en-US',
    double rate = 1.0,
  }) async {
    debugPrint(
      '🔊 TTS.play url=$cdnUrl fallback="$fallbackText"'
      ' locale=$locale rate=$rate',
    );
    await stop();

    // 1. Cache
    final cached = await _cache.get(cdnUrl);
    if (cached != null) {
      debugPrint('🔊 TTS.cache HIT path=${cached.path}');
      _currentSource = SoundSource.cache;
      await _audioManager.playFile(
        cached.path,
        mimeType: 'audio/mpeg',
        rate: rate,
      );
      return SoundSource.cache;
    }
    debugPrint('🔊 TTS.cache MISS → CDN');

    // 2. CDN
    final cdnBytes = await _download(cdnUrl);
    if (cdnBytes != null) {
      debugPrint('🔊 TTS.cdn OK bytes=${cdnBytes.length}');
      final file = await _cache.store(cdnUrl, cdnBytes);
      _currentSource = SoundSource.cdn;
      await _audioManager.playFile(
        file.path,
        mimeType: 'audio/mpeg',
        rate: rate,
      );
      return SoundSource.cdn;
    }
    debugPrint('🔊 TTS.cdn FAILED → device TTS');

    // 3. Device TTS
    if (await _speakDevice(fallbackText, locale, rate)) {
      debugPrint('🔊 TTS.deviceTts started text="$fallbackText"');
      return SoundSource.deviceTts;
    }
    debugPrint('🔊 TTS.deviceTts FAILED → Google TTS');

    // 4. Google TTS (unofficial endpoint; best-effort)
    final googleUrl = _googleTtsUrl(fallbackText, locale);
    final googleKey = 'gtts:$locale:$fallbackText';
    final googleBytes = await _download(
      googleUrl,
      headers: const {
        'User-Agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Bayan/1.0',
        'Referer': 'https://translate.google.com/',
      },
    );
    if (googleBytes != null) {
      debugPrint('🔊 TTS.googleTts OK bytes=${googleBytes.length}');
      final file = await _cache.store(googleKey, googleBytes);
      _currentSource = SoundSource.googleTts;
      await _audioManager.playFile(
        file.path,
        mimeType: 'audio/mpeg',
        rate: rate,
      );
      return SoundSource.googleTts;
    }

    debugPrint('🔊 TTS.googleTts FAILED → giving up');
    throw _SoundPlayException('Could not play "$fallbackText"');
  }

  /// Plays a bundled sound asset (e.g. a phoneme clip). [assetPath] is relative
  /// to the `assets/` root, e.g. `sounds/consonants_k.m4a`. Completion is
  /// reported on [completionStream] as [SoundSource.asset].
  Future<SoundSource> playAsset(String assetPath) async {
    debugPrint('🔊 TTS.playAsset $assetPath');
    await stop();
    _currentSource = SoundSource.asset;
    await _audioManager.playAsset(assetPath);
    return SoundSource.asset;
  }

  /// Speaks [text] through device TTS, skipping CDN / cache entirely. Used
  /// where the corpus has no pre-recorded audio (e.g. grammar examples).
  Future<bool> speak(
    String text, {
    String locale = 'en-US',
    double rate = 1.0,
  }) async {
    debugPrint('🔊 TTS.speak text="$text" locale=$locale rate=$rate');
    await stop();
    return _speakDevice(text, locale, rate);
  }

  Future<void> stop() async {
    if (_currentSource != null) {
      debugPrint('🔊 TTS.stop was=$_currentSource');
    }
    if (_currentSource == SoundSource.deviceTts) {
      await _tts.stop();
    }
    await _audioManager.stop();
    _currentSource = null;
  }

  Future<void> pause() async {
    if (_currentSource == SoundSource.deviceTts) {
      // flutter_tts cannot reliably pause mid-utterance; stop instead.
      await stop();
      return;
    }
    await _audioManager.pause();
  }

  Future<void> resume() async {
    if (_currentSource == SoundSource.deviceTts) return;
    await _audioManager.resume();
  }

  Future<Uint8List?> _download(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final res = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: headers,
          validateStatus: (s) => s != null && s >= 200 && s < 300,
        ),
      );
      final data = res.data;
      if (data != null && data.isNotEmpty) {
        return Uint8List.fromList(data);
      }
      debugPrint('🔊 TTS.download empty body url=$url');
    } catch (e) {
      debugPrint('🔊 TTS.download error url=$url err=$e');
    }
    return null;
  }

  Future<bool> _speakDevice(String text, String locale, double rate) async {
    try {
      await _tts.setLanguage(locale);
      // flutter_tts's rate scale is different from audioplayers — 0.45 sounds
      // like natural English on most engines. Multiply by [rate] so the same
      // slow/normal control affects TTS the same direction as pre-recorded
      // audio (rate 0.65 → 0.29, rate 1.0 → 0.45).
      await _tts.setSpeechRate(0.45 * rate);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(false);
      _currentSource = SoundSource.deviceTts;
      final result = await _tts.speak(text);
      if (result != 1) {
        debugPrint('🔊 TTS.deviceTts speak returned $result — treated as fail');
        _currentSource = null;
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('🔊 TTS.deviceTts exception err=$e');
      _currentSource = null;
      return false;
    }
  }

  String _googleTtsUrl(String text, String locale) {
    final lang = locale.split('-').first;
    final encoded = Uri.encodeQueryComponent(text);
    return 'https://translate.google.com/translate_tts'
        '?ie=UTF-8&q=$encoded&tl=$lang&client=tw-ob'
        '&total=1&idx=0&textlen=${text.length}';
  }

  @disposeMethod
  Future<void> dispose() async {
    debugPrint('🔊 TTS.dispose');
    await _audioCompletionSub?.cancel();
    await _completionController.close();
    await _tts.stop();
    await _audioManager.stop();
  }
}

class _SoundPlayException implements Exception {
  final String message;
  _SoundPlayException(this.message);

  @override
  String toString() => message;
}
