import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/features/dictionary/presentation/widgets/dictionary_search_bar.dart';

Widget _host(DictionarySearchBar bar) => MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: bar,
        ),
      ),
    );

const _clearFinder = 'Clear search'; // _ClearButton Semantics label

void main() {
  group('DictionarySearchBar — Clear button visibility', () {
    testWidgets('Clear is absent on an empty field', (tester) async {
      await tester.pumpWidget(_host(DictionarySearchBar(onChanged: (_) {})));
      await tester.pump();
      expect(find.bySemanticsLabel(_clearFinder), findsNothing);
    });

    testWidgets(
      'Clear appears the instant the field is non-empty '
      '(verifies controller listener drives setState)',
      (tester) async {
        await tester.pumpWidget(_host(DictionarySearchBar(onChanged: (_) {})));
        await tester.enterText(find.byType(TextField), 'anim');
        await tester.pump();
        expect(find.bySemanticsLabel(_clearFinder), findsOneWidget);
      },
    );
  });

  group('DictionarySearchBar — Clear behaviour', () {
    testWidgets(
      'tapping Clear empties the field, immediately fires onChanged("") '
      "once, and keeps the field focused",
      (tester) async {
        final events = <String>[];
        await tester.pumpWidget(_host(
          DictionarySearchBar(onChanged: events.add),
        ));

        // Type something and let the 300ms debounce fire once.
        await tester.enterText(find.byType(TextField), 'anim');
        await tester.pump(const Duration(milliseconds: 350));
        expect(events, ['anim']);

        // Focus the field (as it would be after typing).
        FocusManager.instance.primaryFocus?.requestFocus();
        await tester.pump();

        // Tap the Clear button.
        await tester.tap(find.bySemanticsLabel(_clearFinder));
        await tester.pump();

        // Field is empty.
        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.controller?.text, isEmpty);

        // onChanged('') fired synchronously (no debounce wait).
        expect(events, ['anim', '']);

        // Keyboard focus retained — the TextField still owns primary focus so
        // the user can type a fresh query without re-tapping the field.
        expect(FocusScope.of(tester.element(find.byType(TextField))).hasFocus,
            isTrue);
      },
    );

    testWidgets(
      'typing + Clear does NOT emit any debounced intermediate value for the '
      'typed text after Clear fires (regression: debounce timer gets cancelled)',
      (tester) async {
        final events = <String>[];
        await tester.pumpWidget(_host(
          DictionarySearchBar(onChanged: events.add),
        ));

        await tester.enterText(find.byType(TextField), 'anim');
        // Clear BEFORE the 300ms debounce fires.
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.bySemanticsLabel(_clearFinder));
        await tester.pump(const Duration(milliseconds: 500));

        // Only the Clear's empty event — no leftover 'anim' sneaking through.
        expect(events, ['']);
      },
    );
  });
}
