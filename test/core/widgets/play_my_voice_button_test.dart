import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/widgets/play_my_voice_button.dart';

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );

void main() {
  group('PlayMyVoiceButton', () {
    testWidgets('recordingPath == null → renders a SizedBox.shrink '
        '(callers can wire unconditionally)', (tester) async {
      await tester.pumpWidget(_host(const PlayMyVoiceButton(
        recordingPath: null,
      )));
      await tester.pump();
      // No IconButton rendered.
      expect(find.byType(IconButton), findsNothing);
      // The button itself is in the tree but as a shrink.
      final size = tester.getSize(find.byType(PlayMyVoiceButton));
      expect(size, Size.zero);
    });

    testWidgets('recordingPath set → tapping invokes onPlay with the path',
        (tester) async {
      String? playedPath;
      await tester.pumpWidget(_host(PlayMyVoiceButton(
        recordingPath: '/tmp/practice_take.m4a',
        onPlay: (p) async {
          playedPath = p;
        },
        exists: (_) async => true,
      )));
      await tester.pump();
      expect(find.byIcon(Icons.graphic_eq_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.graphic_eq_rounded));
      await tester.pump();
      expect(playedPath, '/tmp/practice_take.m4a');
    });

    testWidgets(
      'file no longer on disk → onPlay is NEVER called and a quiet '
      'SnackBar explains the recording is gone (TASK 12.1 §D). Covers the '
      'prune/OS-cleanup race between finishing a take and tapping replay.',
      (tester) async {
        var onPlayCalled = false;
        await tester.pumpWidget(_host(PlayMyVoiceButton(
          recordingPath: '/tmp/pruned.m4a',
          exists: (_) async => false,
          onPlay: (_) async {
            onPlayCalled = true;
          },
        )));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.graphic_eq_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
        expect(onPlayCalled, isFalse,
            reason: 'playback must be short-circuited before AudioManager');
        expect(find.text('Recording is no longer available.'), findsOneWidget);
      },
    );

    testWidgets('tooltip reads "Hear what you said"', (tester) async {
      await tester.pumpWidget(_host(const PlayMyVoiceButton(
        recordingPath: '/tmp/x.m4a',
      )));
      await tester.pump();
      expect(find.byTooltip('Hear what you said'), findsOneWidget);
    });

    testWidgets(
      'onPlay throwing (e.g. iOS AVFoundation DarwinAudioError on a '
      'malformed recording) is swallowed and surfaced as a SnackBar — '
      'the exception must NOT propagate up to Crashlytics',
      (tester) async {
        await tester.pumpWidget(_host(PlayMyVoiceButton(
          recordingPath: '/tmp/corrupt.m4a',
          exists: (_) async => true,
          onPlay: (_) async {
            throw Exception('AVPlayerItem.Status.failed on setSourceUrl');
          },
        )));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.graphic_eq_rounded));
        await tester.pump(); // schedule SnackBar
        await tester.pump(const Duration(milliseconds: 200));
        // The exception did not leak out of the tap handler.
        expect(tester.takeException(), isNull);
        // User sees a quiet error line instead.
        expect(find.text('Could not play your recording.'), findsOneWidget);
      },
    );
  });
}
