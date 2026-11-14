import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../bloc/conversation_lessons/conversation_lessons_bloc.dart';
import '../bloc/conversation_lessons/conversation_lessons_event.dart';
import '../bloc/conversation_lessons/conversation_lessons_state.dart';
import '../widgets/conversation_lesson_row.dart';

class ConversationLessonsScreen extends StatelessWidget {
  final int categoryId;
  final String? categoryTitle;

  const ConversationLessonsScreen({
    super.key,
    required this.categoryId,
    this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConversationLessonsBloc>()
        ..add(LoadConversationLessons(categoryId: categoryId)),
      child: Scaffold(
        backgroundColor: BayanColors.screenBg,
        appBar: AppBar(
          backgroundColor: BayanColors.screenBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: BayanColors.onSurface,
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.conversations),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TALK',
                style: BayanTypography.labelMedium.copyWith(
                  fontSize: 11,
                  color: BayanColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1 * 11,
                ),
              ),
              Text(
                categoryTitle ?? 'Lessons',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BayanTypography.titleLarge.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: BayanColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        body: BlocBuilder<ConversationLessonsBloc, ConversationLessonsState>(
          builder: (context, state) {
            final bloc = context.read<ConversationLessonsBloc>();
            return switch (state) {
              ConversationLessonsInitial() ||
              ConversationLessonsLoading() =>
                const Center(child: CircularProgressIndicator()),
              ConversationLessonsError(:final message) => ErrorStateView(
                  message: message,
                  onRetry: () => bloc.add(
                    LoadConversationLessons(categoryId: categoryId),
                  ),
                ),
              ConversationLessonsLoaded(:final lessons, :final progress) =>
                _buildList(context, lessons, progress),
            };
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List lessons, progress) {
    if (lessons.isEmpty) {
      return Center(
        child: Text(
          'No lessons here yet.',
          style: BayanTypography.bodyMedium.copyWith(
            color: BayanColors.textMuted,
          ),
        ),
      );
    }
    final lessonIds =
        lessons.map((l) => l.id).toList(growable: false).cast<int>();
    final (done, total) = progress.categoryCounts(lessonIds);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: lessons.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return _CategoryHeader(done: done, total: total);
        }
        final lesson = lessons[i - 1];
        return ConversationLessonRow(
          lesson: lesson,
          previewCharacters: const [], // populated post-load if needed
          isCompleted: progress.isCompleted(lesson.id) as bool,
          isInProgress: progress.isInProgress(lesson.id) as bool,
          onTap: () => context.push(
            AppRoutes.conversationPlayer(categoryId, lesson.id),
            extra: lesson.title,
          ),
          onRolePlayTap: () => context.push(
            AppRoutes.rolePlaySelect(categoryId, lesson.id),
            extra: lesson.title,
          ),
        );
      },
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final int done;
  final int total;
  const _CategoryHeader({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : done / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$done of $total completed',
            style: BayanTypography.labelLarge.copyWith(
              fontSize: 13,
              color: BayanColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: BayanColors.divider,
              valueColor: AlwaysStoppedAnimation(
                value == 1.0
                    ? BayanColors.successStrong
                    : BayanColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
