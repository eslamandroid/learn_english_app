import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_english_app/base/common_widget/custom_back_button.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../domain/entities/phonetic_topic.dart';
import '../bloc/phonetic_topics/phonetic_topics_bloc.dart';
import '../bloc/phonetic_topics/phonetic_topics_event.dart';
import '../bloc/phonetic_topics/phonetic_topics_state.dart';
import '../widgets/phonetic_current_mastery_card.dart';
import '../widgets/phonetic_topics_grid.dart';
import '../widgets/phonetic_topics_progress_header.dart';

class PhoneticsTopicsScreen extends StatelessWidget {
  final int categoryId;
  final String? categoryTitle;

  const PhoneticsTopicsScreen({
    super.key,
    required this.categoryId,
    this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PhoneticTopicsBloc>()
        ..add(LoadPhoneticTopics(categoryId: categoryId)),
      child: Scaffold(
        backgroundColor: BayanColors.background,
        appBar: AppBar(
          leading: CustomBackButton(onClicked: (){
            context.pop();
          }),
          backgroundColor: BayanColors.background,
          title: Text(
            categoryTitle ?? 'Phonetics',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BayanTypography.headlineMedium.copyWith(
              color: BayanColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: BlocBuilder<PhoneticTopicsBloc, PhoneticTopicsState>(
          builder: (context, state) {
            final bloc = context.read<PhoneticTopicsBloc>();
            return switch (state) {
              PhoneticTopicsInitial() ||
              PhoneticTopicsLoading() =>
                const Center(child: CircularProgressIndicator()),
              PhoneticTopicsError(:final message) => ErrorStateView(
                  message: message,
                  onRetry: () => context
                      .read<PhoneticTopicsBloc>()
                      .add(LoadPhoneticTopics(categoryId: categoryId)),
                ),
              PhoneticTopicsLoaded(:final topics, :final progress) =>
                topics.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: 'No topics yet',
                        message: 'This category has no topics available.',
                      )
                    : _buildLoaded(
                        context,
                        topics: topics,
                        progressHeader: PhoneticTopicsProgressHeader(
                          level: bloc.level,
                          completedCount: _completedInCategory(
                            topics,
                            progress.completedTopicIds,
                          ),
                          totalCount: topics.length,
                        ),
                        currentMasteryCard: _maybeCurrentMasteryCard(
                          context,
                          topics: topics,
                          inProgressId: progress.inProgressTopicId,
                          completedIds: progress.completedTopicIds,
                        ),
                        loadedState: state,
                      ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildLoaded(
    BuildContext context, {
    required List<PhoneticTopic> topics,
    required Widget progressHeader,
    required Widget? currentMasteryCard,
    required PhoneticTopicsLoaded loadedState,
  }) {
    return PhoneticTopicsGrid(
      topics: topics,
      progress: loadedState.progress,
      header: [
        progressHeader,
        if (currentMasteryCard != null) currentMasteryCard,
      ],
      onOpen: (t) => context.push('/phonetics/$categoryId/${t.id}'),
    );
  }

  int _completedInCategory(
    List<PhoneticTopic> topics,
    Set<int> completedIds,
  ) =>
      topics.where((t) => completedIds.contains(t.id)).length;

  Widget? _maybeCurrentMasteryCard(
    BuildContext context, {
    required List<PhoneticTopic> topics,
    required int? inProgressId,
    required Set<int> completedIds,
  }) {
    if (inProgressId == null) return null;
    final idx = topics.indexWhere((t) => t.id == inProgressId);
    if (idx < 0) return null;
    final current = topics[idx];
    final completed = _completedInCategory(topics, completedIds);
    final progress = topics.isEmpty ? 0.0 : completed / topics.length;
    return PhoneticCurrentMasteryCard(
      topicTitle: current.title,
      indexInCategory: idx + 1,
      totalInCategory: topics.length,
      categoryProgress: progress,
      onTap: () => context.push('/phonetics/$categoryId/${current.id}'),
    );
  }
}
