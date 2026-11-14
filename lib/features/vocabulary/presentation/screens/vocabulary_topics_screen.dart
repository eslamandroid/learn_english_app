import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../bloc/vocabulary_topics/vocabulary_topics_bloc.dart';
import '../bloc/vocabulary_topics/vocabulary_topics_event.dart';
import '../bloc/vocabulary_topics/vocabulary_topics_state.dart';
import '../widgets/vocabulary_page_header.dart';
import '../widgets/vocabulary_topics_body.dart';

class VocabularyTopicsScreen extends StatelessWidget {
  const VocabularyTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VocabularyTopicsBloc>()
        ..add(const LoadVocabularyTopics()),
      child: Scaffold(
        backgroundColor: BayanColors.background,
        body: SafeArea(
          child: BlocBuilder<VocabularyTopicsBloc, VocabularyTopicsState>(
            builder: (context, state) {
              final bloc = context.read<VocabularyTopicsBloc>();
              return Column(
                children: [
                  VocabularyPageHeader(
                    label: 'Learn',
                    title: 'Vocabulary',
                    // Back to home — if we were pushed from the dashboard the
                    // pop returns there; otherwise (deep link) fall through
                    // to a direct navigation.
                    onBack: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.dashboard),
                  ),
                  const Divider(
                    height: 1,
                    color: BayanColors.outlineVariant,
                  ),
                  Expanded(
                    child: switch (state) {
                      VocabularyTopicsInitial() ||
                      VocabularyTopicsLoading() =>
                        const Center(child: CircularProgressIndicator()),
                      VocabularyTopicsError(:final message) =>
                        ErrorStateView(
                          message: message,
                          onRetry: () =>
                              bloc.add(const LoadVocabularyTopics()),
                        ),
                      VocabularyTopicsLoaded(:final topics) =>
                        VocabularyTopicsBody(
                          topics: topics,
                          level: bloc.level,
                        ),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
