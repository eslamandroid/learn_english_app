import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:learn_english_app/core/audio/sound_player.dart';
import 'package:learn_english_app/core/speech/sentence_assessment.dart';
import 'package:learn_english_app/features/conversation/domain/entities/conversation_line.dart';
import 'package:learn_english_app/features/conversation/domain/usecases/get_conversation_lines.dart';
import 'package:learn_english_app/features/conversation/presentation/bloc/role_play/role_play_bloc.dart';
import 'package:learn_english_app/features/conversation/presentation/bloc/role_play/role_play_event.dart';
import 'package:learn_english_app/features/conversation/presentation/bloc/role_play/role_play_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetLines extends Mock implements GetConversationLines {}

class _MockSoundPlayer extends Mock implements SoundPlayer {}

ConversationLine _line(int id, String character) => ConversationLine(
      id: id,
      lessonId: 1,
      character: character,
      english: 'Line $id',
      phonetic: '',
      arabic: '',
    );

SentenceAssessment _assessment({required bool passed, required double score}) {
  return SentenceAssessment(
    score: score,
    passed: passed,
    words: const [
      WordResult(word: 'Line', status: WordStatus.correct),
    ],
  );
}

void main() {
  late _MockGetLines getLines;
  late _MockSoundPlayer player;
  late StreamController<SoundSource> completionCtrl;

  setUp(() {
    getLines = _MockGetLines();
    player = _MockSoundPlayer();
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
  });

  tearDown(() async => completionCtrl.close());

  RolePlayBloc build() => RolePlayBloc(getLines, player);

  blocTest<RolePlayBloc, RolePlayState>(
    'first line belongs to the OTHER character → autoPlaying; '
    'user line next → waitingForUser after audio completes',
    build: () {
      when(() => getLines.execute(lessonId: any(named: 'lessonId')))
          .thenAnswer((_) async => Right([
                _line(1, 'Lisa'),
                _line(2, 'James'),
                _line(3, 'Lisa'),
              ]));
      return build();
    },
    act: (b) async {
      b.add(const LoadRolePlay(lessonId: 1, character: 'James'));
      await Future<void>.delayed(Duration.zero);
      // Simulate line 1's audio finishing.
      b.add(const RolePlayAudioCompleted());
    },
    verify: (b) {
      // Line 2 is James's → waitingForUser, pointer at index 1.
      expect(b.state.currentIndex, 1);
      expect(b.state.phase, RolePlayPhase.waitingForUser);
      expect(b.state.isUserTurn, isTrue);
    },
  );

  blocTest<RolePlayBloc, RolePlayState>(
    'first line IS the user → waitingForUser immediately, no audio played',
    build: () {
      when(() => getLines.execute(lessonId: any(named: 'lessonId')))
          .thenAnswer((_) async => Right([
                _line(1, 'James'),
                _line(2, 'Lisa'),
              ]));
      return build();
    },
    act: (b) => b.add(const LoadRolePlay(lessonId: 1, character: 'James')),
    verify: (b) {
      expect(b.state.currentIndex, 0);
      expect(b.state.phase, RolePlayPhase.waitingForUser);
      // Ensure we never asked the sound player for line 1 (it's the user's).
      verifyNever(() => player.play(
            cdnUrl: any(named: 'cdnUrl'),
            fallbackText: any(named: 'fallbackText'),
            locale: any(named: 'locale'),
            rate: any(named: 'rate'),
          ));
    },
  );

  blocTest<RolePlayBloc, RolePlayState>(
    'passing on the first try → attempts==1, passedFirstTry==true, '
    'then auto-advance past passFlashDelay',
    build: () {
      when(() => getLines.execute(lessonId: any(named: 'lessonId')))
          .thenAnswer((_) async => Right([
                _line(1, 'James'),
                _line(2, 'Lisa'),
              ]));
      return build();
    },
    act: (b) async {
      b.add(const LoadRolePlay(lessonId: 1, character: 'James'));
      await Future<void>.delayed(Duration.zero);
      b.add(RolePlayUserAttemptResult(
        lineId: 1,
        assessment: _assessment(passed: true, score: 0.95),
      ));
      // Wait past the auto-advance delay.
      await Future<void>.delayed(
        RolePlayBloc.passFlashDelay + const Duration(milliseconds: 50),
      );
    },
    verify: (b) {
      final r = b.state.results[1];
      expect(r, isNotNull);
      expect(r!.attempts, 1);
      expect(r.passedFirstTry, isTrue);
      expect(r.bestScore, closeTo(0.95, 1e-6));
      // Pointer advanced to Lisa's line (index 1).
      expect(b.state.currentIndex, 1);
      // Lisa's audio is auto-playing.
      expect(b.state.phase, RolePlayPhase.autoPlaying);
    },
  );

  blocTest<RolePlayBloc, RolePlayState>(
    'fail then pass → attempts==2, passedFirstTry==false, bestScore reflects '
    'the highest score across attempts',
    build: () {
      when(() => getLines.execute(lessonId: any(named: 'lessonId')))
          .thenAnswer((_) async => Right([_line(1, 'James'), _line(2, 'Lisa')]));
      return build();
    },
    act: (b) async {
      b.add(const LoadRolePlay(lessonId: 1, character: 'James'));
      await Future<void>.delayed(Duration.zero);
      // First attempt — fail.
      b.add(RolePlayUserAttemptResult(
        lineId: 1,
        assessment: _assessment(passed: false, score: 0.40),
      ));
      await Future<void>.delayed(Duration.zero);
      // Second attempt — pass with higher score.
      b.add(RolePlayUserAttemptResult(
        lineId: 1,
        assessment: _assessment(passed: true, score: 0.90),
      ));
      await Future<void>.delayed(
        RolePlayBloc.passFlashDelay + const Duration(milliseconds: 50),
      );
    },
    verify: (b) {
      final r = b.state.results[1];
      expect(r!.attempts, 2);
      expect(r.passedFirstTry, isFalse);
      expect(r.bestScore, closeTo(0.90, 1e-6));
    },
  );

  blocTest<RolePlayBloc, RolePlayState>(
    'skip after failed attempts → result marked skipped, best score kept, '
    'pointer advances',
    build: () {
      when(() => getLines.execute(lessonId: any(named: 'lessonId')))
          .thenAnswer((_) async => Right([_line(1, 'James'), _line(2, 'Lisa')]));
      return build();
    },
    act: (b) async {
      b.add(const LoadRolePlay(lessonId: 1, character: 'James'));
      await Future<void>.delayed(Duration.zero);
      b.add(RolePlayUserAttemptResult(
        lineId: 1,
        assessment: _assessment(passed: false, score: 0.40),
      ));
      await Future<void>.delayed(Duration.zero);
      b.add(RolePlayUserAttemptResult(
        lineId: 1,
        assessment: _assessment(passed: false, score: 0.55),
      ));
      await Future<void>.delayed(Duration.zero);
      b.add(const RolePlaySkipLine());
      await Future<void>.delayed(Duration.zero);
    },
    verify: (b) {
      final r = b.state.results[1];
      expect(r!.skipped, isTrue);
      expect(r.attempts, 2);
      expect(r.passedFirstTry, isFalse);
      expect(r.bestScore, closeTo(0.55, 1e-6));
      expect(b.state.currentIndex, greaterThan(0));
    },
  );

  blocTest<RolePlayBloc, RolePlayState>(
    'skip is ignored while checking',
    build: () {
      when(() => getLines.execute(lessonId: any(named: 'lessonId')))
          .thenAnswer((_) async => Right([_line(1, 'James'), _line(2, 'Lisa')]));
      return build();
    },
    act: (b) async {
      b.add(const LoadRolePlay(lessonId: 1, character: 'James'));
      await Future<void>.delayed(Duration.zero);
      b.add(const RolePlayStartUserMic());
      await Future<void>.delayed(Duration.zero);
      b.add(const RolePlaySkipLine());
      await Future<void>.delayed(Duration.zero);
    },
    verify: (b) {
      expect(b.state.currentIndex, 0);
      expect(b.state.results[1], isNull);
    },
  );

  blocTest<RolePlayBloc, RolePlayState>(
    'consecutive non-user lines flow through without a waitingForUser pause',
    build: () {
      when(() => getLines.execute(lessonId: any(named: 'lessonId')))
          .thenAnswer((_) async => Right([
                _line(1, 'Lisa'),
                _line(2, 'Lisa'),
                _line(3, 'James'),
              ]));
      return build();
    },
    act: (b) async {
      b.add(const LoadRolePlay(lessonId: 1, character: 'James'));
      await Future<void>.delayed(Duration.zero);
      b.add(const RolePlayAudioCompleted()); // Line 1 done.
      await Future<void>.delayed(Duration.zero);
      b.add(const RolePlayAudioCompleted()); // Line 2 done.
    },
    verify: (b) {
      expect(b.state.currentIndex, 2);
      expect(b.state.phase, RolePlayPhase.waitingForUser);
    },
  );

  blocTest<RolePlayBloc, RolePlayState>(
    'reaching the last line transitions to finished',
    build: () {
      when(() => getLines.execute(lessonId: any(named: 'lessonId')))
          .thenAnswer((_) async => Right([
                _line(1, 'Lisa'),
                _line(2, 'James'),
              ]));
      return build();
    },
    act: (b) async {
      b.add(const LoadRolePlay(lessonId: 1, character: 'James'));
      await Future<void>.delayed(Duration.zero);
      b.add(const RolePlayAudioCompleted()); // Line 1 done → waiting.
      await Future<void>.delayed(Duration.zero);
      b.add(RolePlayUserAttemptResult(
        lineId: 2,
        assessment: _assessment(passed: true, score: 0.88),
      ));
      await Future<void>.delayed(
        RolePlayBloc.passFlashDelay + const Duration(milliseconds: 50),
      );
    },
    verify: (b) {
      expect(b.state.phase, RolePlayPhase.finished);
      expect(b.state.currentIndex, b.state.lines.length);
    },
  );

  blocTest<RolePlayBloc, RolePlayState>(
    'Restart resets results + rewinds to line 0 with the same character',
    build: () {
      when(() => getLines.execute(lessonId: any(named: 'lessonId')))
          .thenAnswer((_) async => Right([
                _line(1, 'James'),
                _line(2, 'Lisa'),
              ]));
      return build();
    },
    act: (b) async {
      b.add(const LoadRolePlay(lessonId: 1, character: 'James'));
      await Future<void>.delayed(Duration.zero);
      b.add(RolePlayUserAttemptResult(
        lineId: 1,
        assessment: _assessment(passed: true, score: 0.9),
      ));
      await Future<void>.delayed(
        RolePlayBloc.passFlashDelay + const Duration(milliseconds: 50),
      );
      b.add(const RolePlayRestart());
      await Future<void>.delayed(Duration.zero);
    },
    verify: (b) {
      expect(b.state.selectedCharacter, 'James');
      expect(b.state.results, isEmpty);
      expect(b.state.currentIndex, 0);
      // Line 0 is James → waiting again.
      expect(b.state.phase, RolePlayPhase.waitingForUser);
    },
  );
}
