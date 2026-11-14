import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/speech/speech_recognition_service.dart';

// Service-level recording concerns (TASK 12.1).
//
// We exercise the two @visibleForTesting statics the service uses to shape
// the on-disk take cache:
//
//   • `nextTakePath` — the per-session filename, which has to be unique for
//     consecutive sessions so a bloc Map that pins one path per item (as
//     SentencePracticeBloc does) does not end up with every entry pointing
//     at the *latest* recording.
//   • `pruneTakes` — the oldest-first retention policy that keeps the
//     temp folder bounded.
//
// We do NOT drive the full plugin-channel stack from here (same reasoning
// documented in TASK 12 session log — mocking `record` and `speech_to_text`
// method channels for a one-value assertion is more noise than signal). The
// end-to-end behavior is covered by the on-device acceptance check.

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('practice_takes_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('SpeechRecognitionService.nextTakePath', () {
    test('two consecutive calls produce distinct paths', () {
      final a = SpeechRecognitionService.nextTakePath(tempDir, counter: 1);
      final b = SpeechRecognitionService.nextTakePath(tempDir, counter: 2);
      expect(a, isNot(equals(b)));
      expect(a, startsWith(tempDir.path));
      expect(a, endsWith('.m4a'));
    });

    test('same microsecond but different counter still distinct '
        '(Windows millisecond-resolution guard)', () {
      final frozen = DateTime.fromMicrosecondsSinceEpoch(1_700_000_000_000_000);
      final a = SpeechRecognitionService.nextTakePath(
        tempDir,
        counter: 1,
        now: frozen,
      );
      final b = SpeechRecognitionService.nextTakePath(
        tempDir,
        counter: 2,
        now: frozen,
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('SpeechRecognitionService.pruneTakes', () {
    test('under cap → no files deleted', () async {
      _writeTakeFiles(tempDir, count: 5);
      await SpeechRecognitionService.pruneTakes(tempDir, keep: 20);
      expect(tempDir.listSync().length, 5);
    });

    test('exactly at cap → no files deleted', () async {
      _writeTakeFiles(tempDir, count: 20);
      await SpeechRecognitionService.pruneTakes(tempDir, keep: 20);
      expect(tempDir.listSync().length, 20);
    });

    test('over cap → oldest-first deletion keeps exactly `keep` files, '
        'and the newest ones survive', () async {
      final paths = _writeTakeFiles(tempDir, count: 25);
      await SpeechRecognitionService.pruneTakes(tempDir, keep: 20);
      final remaining = tempDir
          .listSync()
          .whereType<File>()
          .map((f) => f.path)
          .toSet();
      expect(remaining.length, 20);
      // Oldest 5 (indices 0..4) must be gone.
      for (final gone in paths.take(5)) {
        expect(remaining, isNot(contains(gone)),
            reason: 'expected oldest file to be pruned: $gone');
      }
      // Newest 20 (indices 5..24) must survive.
      for (final kept in paths.skip(5)) {
        expect(remaining, contains(kept),
            reason: 'expected newer file to survive prune: $kept');
      }
    });

    test('missing directory → silent no-op (never throws)', () async {
      final missing = Directory('${tempDir.path}/does_not_exist');
      await expectLater(
        SpeechRecognitionService.pruneTakes(missing, keep: 20),
        completes,
      );
    });

    test('passes keep: _maxTakes-1 pattern used by the service → 19 remain '
        'after calling before a new session (one slot is left for the new '
        'take being started)', () async {
      _writeTakeFiles(tempDir, count: 20);
      // The service calls pruneTakes(..., keep: _maxTakes - 1) BEFORE
      // creating the new take file, so the total post-session is 20 not 21.
      await SpeechRecognitionService.pruneTakes(tempDir, keep: 19);
      expect(tempDir.listSync().length, 19);
    });
  });

  group('SpeechRecognitionService.dropPathIfSilent (TASK 12.2 §C.3, '
      'revised by TASK 12.4 §3 — no "has transcript" condition)', () {
    test('path null → returns null (nothing to validate)', () async {
      final out = await SpeechRecognitionService.dropPathIfSilent(
        path: null,
        peakDbfs: -80,
      );
      expect(out, isNull);
    });

    test('loud capture → path kept (normal success case)', () async {
      final file = File('${tempDir.path}/loud.m4a');
      file.writeAsStringSync('fake');
      final out = await SpeechRecognitionService.dropPathIfSilent(
        path: file.path,
        peakDbfs: -20, // well above the -45 threshold
      );
      expect(out, file.path);
      expect(file.existsSync(), isTrue);
    });

    test('silent capture → path cleared AND file deleted, with or without '
        'a transcript (TASK 12.4 §3: a silent replay button is worse than '
        'no button, even on the "Didn\'t catch that" branch)', () async {
      final file = File('${tempDir.path}/silent.m4a');
      file.writeAsStringSync('fake');
      final out = await SpeechRecognitionService.dropPathIfSilent(
        path: file.path,
        peakDbfs: -120,
      );
      expect(out, isNull);
      expect(file.existsSync(), isFalse);
    });

    test('peak exactly at the threshold → treated as silent '
        '(threshold is inclusive)', () async {
      final file = File('${tempDir.path}/edge.m4a');
      file.writeAsStringSync('fake');
      final out = await SpeechRecognitionService.dropPathIfSilent(
        path: file.path,
        peakDbfs: -45,
      );
      expect(out, isNull);
    });

    test('custom threshold → tunable per-platform without touching '
        'service internals', () async {
      final file = File('${tempDir.path}/tunable.m4a');
      file.writeAsStringSync('fake');
      final out = await SpeechRecognitionService.dropPathIfSilent(
        path: file.path,
        peakDbfs: -20,
        threshold: -10,
      );
      expect(out, isNull);
    });
  });

  group('SpeechRecognitionService.dropPathIfTooShort (TASK 12.4 §2)', () {
    test('path null → null (nothing to validate)', () async {
      final out = await SpeechRecognitionService.dropPathIfTooShort(
        path: null,
        sessionDuration: const Duration(seconds: 5),
        measure: (_) async => const Duration(milliseconds: 250),
      );
      expect(out, isNull);
    });

    test('session under 1.5s → no check; path kept regardless of ratio '
        '(a tap-and-release mic session can legitimately produce a short '
        'file and must not be penalised)', () async {
      final file = File('${tempDir.path}/short_session.m4a');
      file.writeAsStringSync('fake');
      final out = await SpeechRecognitionService.dropPathIfTooShort(
        path: file.path,
        sessionDuration: const Duration(milliseconds: 900),
        measure: (_) async => Duration.zero,
      );
      expect(out, file.path);
      expect(file.existsSync(), isTrue);
    });

    test('5s session, 0.25s file (the exact Android mic-contention '
        'fingerprint from Islam\'s logs) → null + file deleted', () async {
      final file = File('${tempDir.path}/truncated.m4a');
      file.writeAsStringSync('fake');
      final out = await SpeechRecognitionService.dropPathIfTooShort(
        path: file.path,
        sessionDuration: const Duration(seconds: 5),
        measure: (_) async => const Duration(milliseconds: 250),
      );
      expect(out, isNull);
      expect(file.existsSync(), isFalse);
    });

    test('5s session, 4.8s file → path kept (healthy capture)', () async {
      final file = File('${tempDir.path}/healthy.m4a');
      file.writeAsStringSync('fake');
      final out = await SpeechRecognitionService.dropPathIfTooShort(
        path: file.path,
        sessionDuration: const Duration(seconds: 5),
        measure: (_) async => const Duration(milliseconds: 4800),
      );
      expect(out, file.path);
      expect(file.existsSync(), isTrue);
    });

    test('5s session, measurer returns null (plugin couldn\'t read '
        'duration) → path kept — we only drop on positive evidence',
        () async {
      final file = File('${tempDir.path}/measurement_null.m4a');
      file.writeAsStringSync('fake');
      final out = await SpeechRecognitionService.dropPathIfTooShort(
        path: file.path,
        sessionDuration: const Duration(seconds: 5),
        measure: (_) async => null,
      );
      expect(out, file.path);
      expect(file.existsSync(), isTrue);
    });

    test('5s session, measurer throws → path kept (never bring down the '
        'session for a measurement glitch)', () async {
      final file = File('${tempDir.path}/measurement_throws.m4a');
      file.writeAsStringSync('fake');
      final out = await SpeechRecognitionService.dropPathIfTooShort(
        path: file.path,
        sessionDuration: const Duration(seconds: 5),
        measure: (_) async => throw StateError('plugin crashed'),
      );
      expect(out, file.path);
      expect(file.existsSync(), isTrue);
    });

    test('ratio exactly at the floor → path kept (ratio is non-strict '
        '>= so an edge-case capture is not penalised)', () async {
      final file = File('${tempDir.path}/edge_ratio.m4a');
      file.writeAsStringSync('fake');
      final out = await SpeechRecognitionService.dropPathIfTooShort(
        path: file.path,
        sessionDuration: const Duration(seconds: 5),
        measure: (_) async => const Duration(seconds: 3), // 60% exactly
      );
      expect(out, file.path);
      expect(file.existsSync(), isTrue);
    });
  });
}

/// Writes `count` take files with monotonically-increasing modification
/// times. Returns their paths in creation order (oldest first). The modified
/// time is set explicitly instead of relying on `sleep` — on fast systems the
/// `File.create()` calls land within the same filesystem-resolution tick and
/// the sort order becomes unstable.
List<String> _writeTakeFiles(Directory dir, {required int count}) {
  final paths = <String>[];
  final base = DateTime(2024, 1, 1);
  for (var i = 0; i < count; i++) {
    final file = File('${dir.path}/take_${i.toString().padLeft(3, '0')}.m4a');
    file.writeAsStringSync('dummy audio bytes $i');
    file.setLastModifiedSync(base.add(Duration(seconds: i)));
    paths.add(file.path);
  }
  return paths;
}
