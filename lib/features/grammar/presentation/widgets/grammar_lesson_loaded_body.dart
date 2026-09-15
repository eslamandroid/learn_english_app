import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/grammar_rule.dart';
import '../../domain/entities/grammar_rule_example.dart';
import '../bloc/grammar_lesson/grammar_lesson_bloc.dart';
import '../bloc/grammar_lesson/grammar_lesson_event.dart';
import '../bloc/grammar_lesson/grammar_lesson_state.dart';
import 'grammar_example_card.dart';
import 'grammar_rule_card.dart';
import 'grammar_section_heading.dart';
import 'grammar_test_card.dart';

/// Body rendered when the lesson bloc is in the [GrammarLessonLoaded] state:
/// the current rule card, its examples, and the rule's test (if any).
class GrammarLessonLoadedBody extends StatelessWidget {
  final GrammarLessonLoaded state;

  const GrammarLessonLoadedBody({super.key, required this.state});

  /// Flatten every example across this rule's descriptions in display order.
  static List<GrammarRuleExample> _examplesFor(GrammarRule rule) => [
        for (final d in rule.descriptions) ...d.examples,
      ];

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GrammarLessonBloc>();
    final rule = state.currentRule;
    final examples = _examplesFor(rule);
    final test = state.currentRuleTest;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.containerPadding,
        AppConstants.spacingMd,
        AppConstants.containerPadding,
        AppConstants.spacingLg,
      ),
      children: [
        GrammarRuleCard(rule: rule),
        if (examples.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacingLg),
          GrammarSectionHeading(label: context.localization.examplesInAction),
          const SizedBox(height: AppConstants.spacingMd),
          for (final ex in examples) ...[
            GrammarExampleCard(
              example: ex,
              isSpeaking: state.speakingExampleId == ex.id,
              onSpeak: () => bloc.add(SpeakExample(example: ex)),
            ),
            const SizedBox(height: AppConstants.spacingSm),
          ],
        ],
        if (test != null) ...[
          const SizedBox(height: AppConstants.spacingLg),
          GrammarTestCard(
            test: test,
            selected: state.answers[test.id],
            onSelect: (option) =>
                bloc.add(AnswerTest(test: test, option: option)),
          ),
        ],
      ],
    );
  }
}
