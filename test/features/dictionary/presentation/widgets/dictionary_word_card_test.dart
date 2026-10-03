import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/speech/speech_models.dart';
import 'package:learn_english_app/core/speech/speech_recognition_service.dart';
import 'package:learn_english_app/features/dictionary/domain/entities/dictionary_word.dart';
import 'package:learn_english_app/features/dictionary/presentation/widgets/dictionary_word_card.dart';
import 'package:learn_english_app/features/phonetics/domain/entities/pronunciation_outcome.dart';
import 'package:learn_english_app/features/phonetics/presentation/bloc/pronunciation/pronunciation_bloc.dart';
import 'package:learn_english_app/features/phonetics/presentation/bloc/pronunciation/pronunciation_state.dart';
import 'package:learn_english_app/shared/enums/cefr_level.dart';
import 'package:mocktail/mocktail.dart';

class _FakeSpeech extends Fake implements SpeechRecognitionService {
  final _ctrl = StreamController<SpeechRecognitionUpdate>.broadcast();
  @override
  Stream<SpeechRecognitionUpdate> get updates => _ctrl.stream;
  @override
  Future<bool> start({
    bool continuous = false,
    String localeId = 'en_US',
    Duration listenFor = const Duration(seconds: 10),
    Duration pauseFor = const Duration(seconds: 3),
  }) async =>
      true;
  @override
  Future<void> stop() async {}
  @override
  Future<void> cancel() async {}
}

DictionaryWord _word(String english, {bool isSaved = false}) => DictionaryWord(
      id: english.hashCode,
      word: english,
      arabic: 'ع',
      pronunciation: '/test/',
      example: 'An example sentence that is reasonably long.',
      level: CefrLevel.a1,
      isSaved: isSaved,
    );

Widget _host(Widget child) {
  return MediaQuery(
    data: const MediaQueryData(size: Size(360, 780)),
    child: MaterialApp(
      home: Scaffold(
        body: BlocProvider<PronunciationBloc>(
          create: (_) => PronunciationBloc(_FakeSpeech()),
          // Narrow container exposes any flex/overflow bug fast.
          child: SizedBox(
            width: 360,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('DictionaryWordCard — long-word safety', () {
    // Short/common case.
    testWidgets('renders "about" without exception', (tester) async {
      await tester.pumpWidget(_host(DictionaryWordCard(
        word: _word('about'),
        isPlaying: false,
        onPlay: () {},
        onToggleSaved: () {},
      )));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('about'), findsOneWidget);
    });

    // Suffixed noun — real row in word_list (14 chars + " (noun)" when
    // disambiguated).
    testWidgets('renders "responsibility" without exception', (tester) async {
      await tester.pumpWidget(_host(DictionaryWordCard(
        word: _word('responsibility'),
        isPlaying: false,
        onPlay: () {},
        onToggleSaved: () {},
      )));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('responsibility'), findsOneWidget);
    });

    // Actual longest word_list entry — stress case. Also validates the
    // trailing three-button group stays intact (3 CircleAvatar? no — we
    // use a plain Container shape; probe via tooltip texts instead).
    testWidgets(
      'renders longest word_list entry without exception and keeps 3 actions',
      (tester) async {
        const longest = 'lie (verb - to not tell the truth)';
        await tester.pumpWidget(_host(DictionaryWordCard(
          word: _word(longest, isSaved: true),
          isPlaying: false,
          onPlay: () {},
          onToggleSaved: () {},
        )));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text(longest), findsOneWidget);
        // Three trailing circular buttons, identified by their tooltips.
        expect(find.byTooltip('Play audio'), findsOneWidget);
        expect(find.byTooltip('Practice saying it'), findsOneWidget);
        expect(find.byTooltip('Remove from My Words'), findsOneWidget);
      },
    );
  });

  group('DictionaryWordCard — pronunciation feedback', () {
    testWidgets(
      'shows a correct pill when the pronunciation bloc has a correct attempt',
      (tester) async {
        final word = _word('about');
        final bloc = PronunciationBloc(_FakeSpeech());
        // Seed a correct attempt for this word's id.
        // ignore: invalid_use_of_visible_for_testing_member
        bloc.emit(PronunciationState(attempts: {
          word.id: const PronunciationAttempt(
            outcome: PronunciationOutcome.correct,
            heard: 'about',
          ),
        }));
        await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(size: Size(360, 780)),
          child: MaterialApp(
            home: Scaffold(
              body: BlocProvider<PronunciationBloc>.value(
                value: bloc,
                child: SizedBox(
                  width: 360,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DictionaryWordCard(
                      word: word,
                      isPlaying: false,
                      onPlay: () {},
                      onToggleSaved: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.textContaining('Correct'), findsOneWidget);
      },
    );
  });

  group('DictionaryWordCard — toggle save callback', () {
    testWidgets('tapping star fires onToggleSaved', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(_host(DictionaryWordCard(
        word: _word('about'),
        isPlaying: false,
        onPlay: () {},
        onToggleSaved: () => tapped++,
      )));
      await tester.pump();
      await tester.tap(find.byTooltip('Save to My Words'));
      await tester.pump();
      expect(tapped, 1);
    });
  });
}

// Needed so mocktail accepts the Fake even though we don't use any of its
// stubs — satisfies the `Fake implements X` requirement in strict mode.
// ignore: unused_element
class _Unused extends Mock {}
