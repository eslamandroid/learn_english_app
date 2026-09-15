import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../di/di.dart';
import '../../domain/usecases/get_grammar_rule_tests.dart';
import '../widgets/grammar_test_question_preview.dart';

/// Stub — Phase 5 lays down the data layer. Full quiz UI ships in the next
/// pass (option selection, scoring, results), at which point the
/// `FutureBuilder + getIt` pair below moves into a `GrammarTestBloc` per
/// `rules/bloc.md`.
class GrammarTestScreen extends StatelessWidget {
  final int subtopicId;
  const GrammarTestScreen({super.key, required this.subtopicId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BayanColors.background,
      appBar: AppBar(
        title: Text(context.localization.practice),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder(
        future: getIt<GetGrammarRuleTests>().execute(subtopicId: subtopicId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final either = snap.data;
          if (either == null) return const SizedBox.shrink();
          return either.fold(
            (e) => Center(child: Text(e.toString())),
            (tests) => tests.isEmpty
                ? Center(child: Text(context.localization.noQuestionsYet))
                : ListView.separated(
                    padding:
                        const EdgeInsets.all(AppConstants.containerPadding),
                    itemCount: tests.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppConstants.spacingMd),
                    itemBuilder: (_, i) => GrammarTestQuestionPreview(
                      index: i + 1,
                      test: tests[i],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
