import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:learn_english_app/core/audio/sound_player.dart';
import 'package:learn_english_app/features/conversation/domain/entities/conversation_line.dart';
import 'package:learn_english_app/features/conversation/domain/usecases/get_conversation_lines.dart';
import 'package:learn_english_app/features/conversation/presentation/bloc/conversation_player/conversation_player_bloc.dart';
import 'package:learn_english_app/features/conversation/presentation/bloc/conversation_player/conversation_player_event.dart';
import 'package:learn_english_app/features/conversation/presentation/bloc/conversation_player/conversation_player_state.dart';
import 'package:learn_english_app/features/progress/domain/usecases/mark_conversation_lesson_completed.dart';
import 'package:learn_english_app/features/progress/domain/usecases/mark_conversation_lesson_started.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetLines extends Mock implements GetConversationLines {}

class _MockSoundPlayer extends Mock implements SoundPlayer {}

class _MockMarkStarted extends Mock
    implements MarkConversationLessonStarted {}

class _MockMarkCompleted extends Mock
    implements MarkConversationLessonCompleted {}

ConversationLine _line(int id) => ConversationLine(
      id: id,
      lessonId: 1,
      character: id.isOdd ? 'James' : 'Lisa',
      english: 'Line $id',
      phonetic: '',
      arabic: '',
    );

void main() {
  late _MockGetLines getLines;
  late _MockSoundPlayer player;
  late _MockMarkStarted markStarted;
  late _MockMarkCompleted markCompleted;
  late StreamController<SoundSource> completionCtrl;

  setUp(() {
    getLines = _MockGetLines();
    player = _MockSoundPlayer();
    markStarted = _MockMarkStarted();
    markCompleted = _MockMarkCompleted();
    completionCtrl = StreamController<SoundSource>.broadcast();

    when(() => player.completionStream)
        .thenAnswer((_) => completionCtrl.stream);
    when(() => player.stop()).thenAnswer((_) async {});
    when(() => player.play(
          cdnUrl: any(named: 'cdnUrl'),
          fallbackText: any(named: 'fallbackText'),
          locale: any(named: 'locale'),
          rate: any(named: 'rate'),
        )).thenAnswer((_) async => SoundSource.cdn);
    when(() => markStarted.execute(lessonId: any(named: 'lessonId')))
        .thenAnswer((_) async => const Right(null));
    when(() => markCompleted.execute(lessonId: any(named: 'lessonId')))
        .thenAnswer((_) async => const Right(null));
  });

  tearDown(() async {
    await completionCtrl.close();
  });

  ConversationPlayerBloc build() => ConversationPlayerBloc(
        getLines,
        player,
        markStarted,
        markCompleted,
      );

  blocTest<ConversationPlayerBloc, ConversationPlayerState>(
    'load → loaded with lines, no auto-play yet',
    build: () {
      when(() => getLines.execute(lessonId: any(named: 'lessonId')))
          .thenAnswer(
        (_) async => Right([_line(1), _line(2), _line(3)]),
      );
      return build();
    },
    act: (b) => b.add(const LoadConversationLines(lessonId: 1)),
    expect: () => [
      isA<ConversationPlayerState>()
          .having((s) => s.status, 'status', ConversationPlayerStatus.loading),
      isA<ConversationPlayerState>()
          .having((s) => s.status, 'status', ConversationPlayerStatus.loaded)
          .having((s) => s.lines.length, 'lines.length', 3)
          .having((s) => s.isAutoPlaying, 'isAutoPlaying', false),
    ],
    verify: (_) {
      verify(() => markStarted.execute(lessonId: 1)).called(1);
    },
  );

  blocTest<ConversationPlayerBloc, ConversationPlayerState>(
    'PlaySequence → audio completion advances to next line, '
    'and finally stops at the last line (no auto-play between lessons)',
    build: () {
      when(() => getLines.execute(lessonId: any(named: 'lessonId')))
          .thenAnswer((_) async => Right([_line(1), _line(2)]));
      return build();
    },
    act: (b) async {
      b.add(const LoadConversationLines(lessonId: 1));
      await Future<void>.delayed(Duration.zero);
      b.add(const PlayConversationSequence());
      await Future<void>.delayed(Duration.zero);
      // Simulate line 1 finishing.
      b.add(const ConversationAudioCompleted());
      await Future<void>.delayed(Duration.zero);
      // Simulate line 2 finishing — should stop, not advance.
      b.add(const ConversationAudioCompleted());
    },
    verify: (bloc) {
      expect(bloc.state.currentIndex, 1);
      expect(bloc.state.isAutoPlaying, isFalse);
      expect(bloc.state.playingLineId, isNull);
    },
  );

  blocTest<ConversationPlayerBloc, ConversationPlayerState>(
    'PlaySingle sets isSinglePlay and does NOT advance on completion',
    build: () {
      when(() => getLines.execute(lessonId: any(named: 'lessonId')))
          .thenAnswer((_) async => Right([_line(1), _line(2), _line(3)]));
      return build();
    },
    act: (b) async {
      b.add(const LoadConversationLines(lessonId: 1));
      await Future<void>.delayed(Duration.zero);
      // Point sequence at line 2 but single-play line 3.
      b.add(const JumpToConversationLine(1));
      await Future<void>.delayed(Duration.zero);
      b.add(const PlayConversationSingle(3));
      await Future<void>.delayed(Duration.zero);
      b.add(const ConversationAudioCompleted());
    },
    verify: (bloc) {
      // Sequence pointer stays at 1 (the line user was on before single-play).
      expect(bloc.state.currentIndex, 1);
      expect(bloc.state.isSinglePlay, isFalse);
      expect(bloc.state.playingLineId, isNull);
      expect(bloc.state.isAutoPlaying, isFalse);
    },
  );

  blocTest<ConversationPlayerBloc, ConversationPlayerState>(
    'MarkConversationComplete emits isCompleted and calls the usecase',
    build: () {
      when(() => getLines.execute(lessonId: any(named: 'lessonId')))
          .thenAnswer((_) async => Right([_line(1)]));
      return build();
    },
    act: (b) async {
      b.add(const LoadConversationLines(lessonId: 1));
      await Future<void>.delayed(Duration.zero);
      b.add(const MarkConversationComplete(lessonId: 1));
    },
    verify: (bloc) {
      expect(bloc.state.isCompleted, isTrue);
      verify(() => markCompleted.execute(lessonId: 1)).called(1);
    },
  );
}
