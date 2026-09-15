import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../bloc/grammar_lesson/grammar_lesson_bloc.dart';
import '../bloc/grammar_lesson/grammar_lesson_event.dart';
import '../bloc/grammar_lesson/grammar_lesson_state.dart';
import '../widgets/grammar_lesson_header.dart';
import '../widgets/grammar_lesson_loaded_body.dart';
import '../widgets/grammar_next_rule_bar.dart';

class GrammarLessonScreen extends StatelessWidget {
  final int subtopicId;
  const GrammarLessonScreen({super.key, required this.subtopicId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GrammarLessonBloc>()
        ..add(LoadGrammarLesson(subtopicId: subtopicId)),
      child: BlocBuilder<GrammarLessonBloc, GrammarLessonState>(
        builder: (context, state) {
          final bloc = context.read<GrammarLessonBloc>();
          final loaded = state is GrammarLessonLoaded ? state : null;

          return Scaffold(
            backgroundColor: BayanColors.background,
            appBar: GrammarLessonHeader(
              title: loaded?.lesson.subtopic.title ??
                  context.localization.lesson,
              titleAr: loaded?.lesson.subtopic.titleAr,
              level: bloc.level,
              progress: loaded?.progress ?? 0,
              onBack: () => context.pop(),
            ),
            body: switch (state) {
              GrammarLessonInitial() ||
              GrammarLessonLoading() =>
                const Center(child: CircularProgressIndicator()),
              GrammarLessonError(:final message) => ErrorStateView(
                  message: message,
                  onRetry: () => bloc
                      .add(LoadGrammarLesson(subtopicId: subtopicId)),
                ),
              GrammarLessonLoaded() =>
                GrammarLessonLoadedBody(state: state),
              _ => const SizedBox.shrink(),
            },
            bottomNavigationBar: loaded == null
                ? null
                : GrammarNextRuleBar(
                    hasPrev: loaded.hasPrev,
                    hasNext: loaded.hasNext,
                    onPrev: () => bloc.add(const PreviousRule()),
                    onNext: () => bloc.add(const NextRule()),
                    onFinish: () {
                      bloc.add(const FinishLesson());
                      context.pop();
                    },
                  ),
          );
        },
      ),
    );
  }
}
