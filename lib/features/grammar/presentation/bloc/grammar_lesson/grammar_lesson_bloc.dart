import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/audio/sound_player.dart';
import '../../../../../core/usecases/get_selected_level.dart';
import '../../../../../shared/enums/cefr_level.dart';
import '../../../../progress/domain/usecases/mark_grammar_lesson_completed.dart';
import '../../../../progress/domain/usecases/mark_grammar_lesson_started.dart';
import '../../../domain/entities/grammar_rule_test.dart';
import '../../../domain/usecases/get_grammar_lesson.dart';
import '../../../domain/usecases/get_grammar_rule_tests.dart';
import 'grammar_lesson_event.dart';
import 'grammar_lesson_state.dart';

@injectable
class GrammarLessonBloc extends Bloc<GrammarLessonEvent, GrammarLessonState> {
  final GetGrammarLesson _getLesson;
  final GetGrammarRuleTests _getTests;
  final SoundPlayer _soundPlayer;
  final GetSelectedLevel _getLevel;
  final MarkGrammarLessonStarted _markStarted;
  final MarkGrammarLessonCompleted _markCompleted;

  StreamSubscription<SoundSource>? _completionSub;

  CefrLevel get level => _getLevel.current();

  GrammarLessonBloc(
    this._getLesson,
    this._getTests,
    this._soundPlayer,
    this._getLevel,
    this._markStarted,
    this._markCompleted,
  ) : super(const GrammarLessonInitial()) {
    on<LoadGrammarLesson>(_onLoad);
    on<GoToRule>(_onGoTo);
    on<NextRule>(_onNext);
    on<PreviousRule>(_onPrev);
    on<FinishLesson>(_onFinish);
    on<AnswerTest>(_onAnswer);
    on<SpeakExample>(_onSpeak);
    on<SilenceExample>(_onSilence);

    _completionSub = _soundPlayer.completionStream
        .listen((_) => add(const SilenceExample()));
  }

  Future<void> _onLoad(
    LoadGrammarLesson event,
    Emitter<GrammarLessonState> emit,
  ) async {
    emit(const GrammarLessonLoading());

    final lessonFut = _getLesson.execute(subtopicId: event.subtopicId);
    final testsFut = _getTests.execute(subtopicId: event.subtopicId);

    final lessonEither = await lessonFut;
    final testsEither = await testsFut;

    lessonEither.fold(
      (e) => emit(GrammarLessonError(message: e.toString())),
      (lesson) {
        if (lesson == null || lesson.rules.isEmpty) {
          emit(const GrammarLessonError(message: 'Lesson has no content.'));
          return;
        }
        final tests = testsEither.fold<List<GrammarRuleTest>>(
          (_) => const [],
          (t) => t,
        );
        emit(GrammarLessonLoaded(
          lesson: lesson,
          tests: tests,
          currentRuleIndex: 0,
        ));

        // Fire-and-forget — flips the progress store to "in progress" so
        // the dashboard's Continue card and the topics screen reflect it.
        _markStarted.execute(subtopicId: event.subtopicId);
      },
    );
  }

  Future<void> _onGoTo(GoToRule event, Emitter<GrammarLessonState> emit) async {
    final s = state;
    if (s is! GrammarLessonLoaded) return;
    final i = event.index.clamp(0, s.lesson.rules.length - 1);
    if (i == s.currentRuleIndex) return;
    await _soundPlayer.stop();
    emit(s.copyWith(currentRuleIndex: i, clearSpeakingExample: true));
  }

  Future<void> _onNext(NextRule event, Emitter<GrammarLessonState> emit) async {
    final s = state;
    if (s is! GrammarLessonLoaded || !s.hasNext) return;
    add(GoToRule(index: s.currentRuleIndex + 1));
  }

  Future<void> _onPrev(
    PreviousRule event,
    Emitter<GrammarLessonState> emit,
  ) async {
    final s = state;
    if (s is! GrammarLessonLoaded || !s.hasPrev) return;
    add(GoToRule(index: s.currentRuleIndex - 1));
  }

  Future<void> _onFinish(
    FinishLesson event,
    Emitter<GrammarLessonState> emit,
  ) async {
    final s = state;
    if (s is! GrammarLessonLoaded) return;
    await _markCompleted.execute(subtopicId: s.lesson.subtopic.id);
  }

  void _onAnswer(AnswerTest event, Emitter<GrammarLessonState> emit) {
    final s = state;
    if (s is! GrammarLessonLoaded) return;
    emit(s.copyWith(
      answers: {...s.answers, event.test.id: event.option},
    ));
  }

  Future<void> _onSpeak(
    SpeakExample event,
    Emitter<GrammarLessonState> emit,
  ) async {
    final s = state;
    if (s is! GrammarLessonLoaded) return;

    if (s.speakingExampleId == event.example.id) {
      await _soundPlayer.stop();
      emit(s.copyWith(clearSpeakingExample: true));
      return;
    }

    emit(s.copyWith(speakingExampleId: event.example.id));
    final ok = await _soundPlayer.speak(event.example.textEn);
    if (!ok) {
      add(const SilenceExample());
    }
  }

  Future<void> _onSilence(
    SilenceExample event,
    Emitter<GrammarLessonState> emit,
  ) async {
    final s = state;
    if (s is! GrammarLessonLoaded) return;
    emit(s.copyWith(clearSpeakingExample: true));
  }

  @override
  Future<void> close() async {
    await _completionSub?.cancel();
    await _soundPlayer.stop();
    return super.close();
  }
}
