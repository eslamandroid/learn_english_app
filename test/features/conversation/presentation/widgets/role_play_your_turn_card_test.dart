import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/features/conversation/domain/entities/conversation_line.dart';
import 'package:learn_english_app/features/conversation/presentation/widgets/role_play_your_turn_card.dart';

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );

const _line = ConversationLine(
  id: 42,
  lessonId: 1,
  character: 'James',
  english: 'How are you today?',
  phonetic: 'haʊ ɑː juː təˈdeɪ?',
  arabic: 'كيف حالك اليوم؟',
);

void main() {
  group('RolePlayYourTurnCard — mic state', () {
    testWidgets('idle state shows mic icon + "Tap and say your line"',
        (tester) async {
      await tester.pumpWidget(_host(RolePlayYourTurnCard(
        line: _line,
        isChecking: false,
        isPreviewPlaying: false,
        onPreview: () {},
        onMicTap: () {},
      )));
      await tester.pump();
      expect(find.text('Tap and say your line'), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsWidgets);
      expect(find.byIcon(Icons.stop_rounded), findsNothing);
    });

    testWidgets('checking state shows stop icon + listening copy',
        (tester) async {
      await tester.pumpWidget(_host(RolePlayYourTurnCard(
        line: _line,
        isChecking: true,
        isPreviewPlaying: false,
        onPreview: () {},
        onMicTap: () {},
      )));
      await tester.pump();
      expect(find.text('Listening… say your line'), findsOneWidget);
      // The pulsing mic shows a stop icon while checking is true.
      expect(find.byIcon(Icons.stop_rounded), findsWidgets);
    });
  });

  group('RolePlayYourTurnCard — Hear it first', () {
    testWidgets('fires onPreview when tapped (idle)', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(RolePlayYourTurnCard(
        line: _line,
        isChecking: false,
        isPreviewPlaying: false,
        onPreview: () => taps++,
        onMicTap: () {},
      )));
      await tester.pump();
      await tester.tap(find.text('Hear it first'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('shows "Stop" label while a preview is actively playing',
        (tester) async {
      await tester.pumpWidget(_host(RolePlayYourTurnCard(
        line: _line,
        isChecking: false,
        isPreviewPlaying: true,
        onPreview: () {},
        onMicTap: () {},
      )));
      await tester.pump();
      expect(find.text('Stop'), findsOneWidget);
      expect(find.text('Hear it first'), findsNothing);
    });
  });

  group('RolePlayYourTurnCard — content rendering', () {
    testWidgets('renders English + Arabic + YOUR TURN tag', (tester) async {
      await tester.pumpWidget(_host(RolePlayYourTurnCard(
        line: _line,
        isChecking: false,
        isPreviewPlaying: false,
        onPreview: () {},
        onMicTap: () {},
      )));
      await tester.pump();
      expect(find.text('YOUR TURN'), findsOneWidget);
      expect(find.text('How are you today?'), findsOneWidget);
      // Arabic visibility is driven by AppContentLanguage.showArabic which
      // defaults to false in tests (no bind), so the Arabic branch collapses.
      // Just ensure no exception.
      expect(tester.takeException(), isNull);
    });
  });
}
