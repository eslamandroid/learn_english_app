import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/features/conversation/domain/entities/conversation_line.dart';
import 'package:learn_english_app/features/conversation/presentation/widgets/conversation_bubble.dart';

ConversationLine _line(String english, {int id = 1, String character = 'James'}) =>
    ConversationLine(
      id: id,
      lessonId: 1,
      character: character,
      english: english,
      phonetic: '',
      arabic: '',
    );

Widget _host(Widget bubble, {double width = 390}) {
  return MediaQuery(
    data: MediaQueryData(size: Size(width, 844)),
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: bubble,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('ConversationBubble — side alignment', () {
    testWidgets('alignRight: false → outer Align is centerLeft', (tester) async {
      await tester.pumpWidget(_host(ConversationBubble(
        line: _line('Hello.'),
        alignRight: false,
        isCurrent: false,
        isUpcoming: false,
        isPlaying: false,
        attempt: null,
        isListening: false,
        onPlay: () {},
        onMic: () {},
      )));
      await tester.pump();
      final align = tester.widget<Align>(find.descendant(
        of: find.byType(ConversationBubble),
        matching: find.byType(Align),
      ).first);
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('alignRight: true → outer Align is centerRight', (tester) async {
      await tester.pumpWidget(_host(ConversationBubble(
        line: _line('Hi.', character: 'Lisa'),
        alignRight: true,
        isCurrent: false,
        isUpcoming: false,
        isPlaying: false,
        attempt: null,
        isListening: false,
        onPlay: () {},
        onMic: () {},
      )));
      await tester.pump();
      final align = tester.widget<Align>(find.descendant(
        of: find.byType(ConversationBubble),
        matching: find.byType(Align),
      ).first);
      expect(align.alignment, Alignment.centerRight);
    });
  });

  group('ConversationBubble — width cap', () {
    testWidgets(
      'short line does not stretch to the viewport width '
      '(ConstrainedBox applies 84% cap)',
      (tester) async {
        const viewportWidth = 390.0;
        await tester.pumpWidget(_host(
          ConversationBubble(
            line: _line('Hi.'),
            alignRight: false,
            isCurrent: false,
            isUpcoming: false,
            isPlaying: false,
            attempt: null,
            isListening: false,
            onPlay: () {},
            onMic: () {},
          ),
          width: viewportWidth,
        ));
        await tester.pump();

        // The ConstrainedBox has the correct cap.
        final constrained = tester.widget<ConstrainedBox>(find.descendant(
          of: find.byType(ConversationBubble),
          matching: find.byType(ConstrainedBox),
        ).first);
        expect(
          constrained.constraints.maxWidth,
          closeTo(viewportWidth * 0.84, 0.5),
        );

        // And the laid-out Row width is well below viewport width — a short
        // "Hi." should hug its own content, not the 84% cap.
        final rowSize = tester.getSize(find.descendant(
          of: find.byType(ConstrainedBox),
          matching: find.byType(Row),
        ).first);
        expect(rowSize.width, lessThan(viewportWidth * 0.84));
      },
    );
  });

  group('ConversationBubble — avatar ordering', () {
    testWidgets('alignRight: false → avatar comes before bubble in the Row',
        (tester) async {
      await tester.pumpWidget(_host(ConversationBubble(
        line: _line('Hello.'),
        alignRight: false,
        isCurrent: false,
        isUpcoming: false,
        isPlaying: false,
        attempt: null,
        isListening: false,
        onPlay: () {},
        onMic: () {},
      )));
      await tester.pump();
      // The CharacterAvatar's horizontal position is left of the bubble's.
      final avatarCenter =
          tester.getCenter(find.byKey(const ValueKey('avatar'))
              .evaluate()
              .isNotEmpty
          ? find.byKey(const ValueKey('avatar'))
          : find.byType(Container).first);
      // The bubble container is the Container that holds the English text.
      final bubbleCenter =
          tester.getCenter(find.text('Hello.'));
      expect(avatarCenter.dx, lessThan(bubbleCenter.dx));
    });

    testWidgets('alignRight: true → avatar comes AFTER bubble in the Row',
        (tester) async {
      await tester.pumpWidget(_host(ConversationBubble(
        line: _line('Hi.', character: 'Lisa'),
        alignRight: true,
        isCurrent: false,
        isUpcoming: false,
        isPlaying: false,
        attempt: null,
        isListening: false,
        onPlay: () {},
        onMic: () {},
      )));
      await tester.pump();
      final letterCenter = tester.getCenter(find.text('L'));
      final bubbleTextCenter = tester.getCenter(find.text('Hi.'));
      // For a right-aligned speaker, the avatar's "L" sits to the right of
      // the bubble text.
      expect(letterCenter.dx, greaterThan(bubbleTextCenter.dx));
    });
  });
}
