import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../bloc/grammar_topics/grammar_topics_bloc.dart';
import '../bloc/grammar_topics/grammar_topics_event.dart';
import '../bloc/grammar_topics/grammar_topics_state.dart';
import '../widgets/grammar_topics_body.dart';

class GrammarTopicsScreen extends StatelessWidget {
  const GrammarTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GrammarTopicsBloc>()
        ..add(const LoadGrammarTopics()),
      child: Scaffold(
        backgroundColor: BayanColors.background,
        // appBar: AppBar(
        //   leading: CustomBackButton(onClicked: context.pop),
        //   title: Text(
        //     context.localization.grammar,
        //     maxLines: 1,
        //     overflow: TextOverflow.ellipsis,
        //     style: BayanTypography.headlineMedium.copyWith(
        //       color: BayanColors.onSurface,
        //       fontWeight: FontWeight.w700,
        //     ),
        //   ),
        // ),
        body: SafeArea(
          child: BlocBuilder<GrammarTopicsBloc, GrammarTopicsState>(
            builder: (context, state) {
              final bloc = context.read<GrammarTopicsBloc>();
              return switch (state) {
                GrammarTopicsInitial() ||
                GrammarTopicsLoading() =>
                  const Center(child: CircularProgressIndicator()),
                GrammarTopicsError(:final message) => ErrorStateView(
                    message: message,
                    onRetry: () =>
                        bloc.add(const LoadGrammarTopics()),
                  ),
                GrammarTopicsLoaded() =>
                  GrammarTopicsBody(state: state, level: bloc.level),
                _ => const SizedBox.shrink(),
              };
            },
          ),
        ),
      ),
    );
  }
}
