import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../bloc/vocabulary_subtopics/vocabulary_subtopics_bloc.dart';
import '../bloc/vocabulary_subtopics/vocabulary_subtopics_event.dart';
import '../bloc/vocabulary_subtopics/vocabulary_subtopics_state.dart';
import '../widgets/vocabulary_page_header.dart';
import '../widgets/vocabulary_subtopics_body.dart';

class VocabularySubtopicsScreen extends StatelessWidget {
  final int topicId;

  /// Optional bilingual title forwarded via `state.extra` from the topics
  /// list — lets us show a real topic name in the header without a second
  /// query for the topic row.
  final String? topicTitle;

  const VocabularySubtopicsScreen({
    super.key,
    required this.topicId,
    this.topicTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VocabularySubtopicsBloc>()
        ..add(LoadVocabularySubtopics(topicId: topicId)),
      child: Scaffold(
        backgroundColor: BayanColors.background,
        body: SafeArea(
          child:
              BlocBuilder<VocabularySubtopicsBloc, VocabularySubtopicsState>(
            builder: (context, state) {
              final bloc = context.read<VocabularySubtopicsBloc>();
              return Column(
                children: [
                  VocabularyPageHeader(
                    label: 'Subtopics',
                    title: topicTitle ?? 'Subtopics',
                    onBack: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.vocabulary),
                  ),
                  const Divider(
                    height: 1,
                    color: BayanColors.outlineVariant,
                  ),
                  Expanded(
                    child: switch (state) {
                      VocabularySubtopicsInitial() ||
                      VocabularySubtopicsLoading() =>
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      VocabularySubtopicsError(:final message) =>
                        ErrorStateView(
                          message: message,
                          onRetry: () => bloc.add(
                            LoadVocabularySubtopics(topicId: topicId),
                          ),
                        ),
                      VocabularySubtopicsLoaded(:final subtopics) =>
                        VocabularySubtopicsBody(
                          topicId: topicId,
                          topicTitle: topicTitle,
                          subtopics: subtopics,
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
