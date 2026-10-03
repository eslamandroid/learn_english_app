import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/features/sentences/presentation/widgets/sentence_topic_illustration.dart';

void main() {
  group('SentenceTopicIllustration.assetFor', () {
    test('known key → direct asset path', () {
      expect(
        SentenceTopicIllustration.assetFor('ph_basic'),
        'assets/icons/ph_basic.svg',
      );
    });

    test('unknown key → falls back to ph_other', () {
      expect(
        SentenceTopicIllustration.assetFor('ph_unknown'),
        'assets/icons/ph_other.svg',
      );
    });

    test('null key → falls back to ph_other', () {
      expect(
        SentenceTopicIllustration.assetFor(null),
        'assets/icons/ph_other.svg',
      );
    });
  });

  testWidgets(
    'renders without throwing when the icon key is unknown',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SentenceTopicIllustration(
                iconKey: 'ph_definitely_not_a_real_key',
                size: 40,
              ),
            ),
          ),
        ),
      );
      // No exception during build/layout: the widget must substitute the
      // ph_other asset without throwing.
      expect(tester.takeException(), isNull);
      expect(find.byType(SentenceTopicIllustration), findsOneWidget);
    },
  );

  testWidgets(
    'renders without throwing when the icon key is null',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SentenceTopicIllustration(iconKey: null, size: 40),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(SentenceTopicIllustration), findsOneWidget);
    },
  );
}
