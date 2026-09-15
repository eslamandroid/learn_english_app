import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Persistent on-disk cache for downloaded audio clips.
///
/// Keys are arbitrary strings (typically the source URL). One key → one file
/// on disk. Files are stored under the platform's application cache directory
/// — the OS may evict them under storage pressure, which is the expected
/// behaviour for derived/redownloadable assets.
@lazySingleton
class SoundCache {
  static const _subdir = 'sound_cache';

  Directory? _dir;

  Future<Directory> _ensureDir() async {
    final cached = _dir;
    if (cached != null) return cached;
    final base = await getApplicationCacheDirectory();
    final dir = Directory(p.join(base.path, _subdir));
    if (!await dir.exists()) await dir.create(recursive: true);
    _dir = dir;
    return dir;
  }

  // Files keep their real extension so platform players (notably iOS
  // AVFoundation) can infer the codec from the path.
  String _fileName(String key, String extension) {
    final hash = sha1.convert(utf8.encode(key)).toString();
    return '$hash.$extension';
  }

  Future<File> _fileFor(String key, String extension) async {
    final dir = await _ensureDir();
    return File(p.join(dir.path, _fileName(key, extension)));
  }

  /// Returns the cached file for [key] if present, else `null`.
  Future<File?> get(String key, {String extension = 'mp3'}) async {
    final f = await _fileFor(key, extension);
    return await f.exists() ? f : null;
  }

  /// Writes [bytes] to the cache under [key] and returns the resulting file.
  Future<File> store(
    String key,
    Uint8List bytes, {
    String extension = 'mp3',
  }) async {
    final f = await _fileFor(key, extension);
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  /// Best-effort total cache size in bytes (sum of file sizes).
  Future<int> sizeBytes() async {
    final dir = await _ensureDir();
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list()) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }

  /// Clears the entire cache directory.
  Future<void> clear() async {
    final dir = await _ensureDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      _dir = null;
    }
  }
}
