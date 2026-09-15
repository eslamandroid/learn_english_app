import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../progress/domain/entities/current_grammar_lesson.dart';
import '../../domain/entities/dashboard_stats.dart';
import 'dashboard_greeting.dart';
import 'featured_lesson_card.dart';
import 'learning_modules_grid.dart';
import 'weekly_overview_card.dart';

/// Scrollable body of the dashboard. Header / app-bar live in the screen;
/// this widget renders the loaded content (greeting, hero, grid, weekly).
class DashboardLoadedBody extends StatelessWidget {
  final DashboardStats stats;
  final String userName;
  final CurrentGrammarLesson? currentLesson;

  const DashboardLoadedBody({
    super.key,
    required this.stats,
    required this.userName,
    required this.currentLesson,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.localization;

    final modules = <LearningModuleEntry>[
      LearningModuleEntry(
        title: l.vocabularyLabel,
        tagline: l.vocabularyTagline(1240),
        icon: Icons.menu_book_rounded,
        accent: BayanColors.primary,
        progress: stats.moduleProgress['vocabulary'] ?? 0,
        onTap: () => context.push(AppRoutes.vocabulary),
      ),
      LearningModuleEntry(
        title: l.grammarLabel,
        tagline: l.grammarTagline,
        icon: Icons.architecture_rounded,
        accent: BayanColors.success,
        progress: stats.moduleProgress['grammar'] ?? 0,
        onTap: () => context.push(AppRoutes.grammar),
      ),
      LearningModuleEntry(
        title: l.sentencesLabel,
        tagline: l.sentencesTagline,
        icon: Icons.format_quote_rounded,
        accent: BayanColors.tertiary,
        progress: stats.moduleProgress['sentences'] ?? 0,
        onTap: () => context.push(AppRoutes.sentences),
      ),
      LearningModuleEntry(
        title: l.phoneticsLabel,
        tagline: l.phoneticsTagline,
        icon: Icons.record_voice_over_rounded,
        accent: BayanColors.error,
        progress: stats.moduleProgress['phonetics'] ?? 0,
        onTap: () => context.push(AppRoutes.phonetics),
      ),
    ];

    final lesson = currentLesson;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.containerPadding,
        AppConstants.spacingLg,
        AppConstants.containerPadding,
        AppConstants.spacingXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardGreeting(
            userName: userName,
            streakDays: stats.currentStreak,
          ),
          const SizedBox(height: AppConstants.spacingLg),
          if (lesson != null)
            FeaturedLessonCard(
              moduleTag: l.grammarLabel,
              title: lesson.subtopic.title,
              titleAr: lesson.subtopic.titleAr,
              icon: Icons.architecture_rounded,
              progress: lesson.topicProgress,
              onContinue: () => context.go(
                AppRoutes.grammarLesson(
                  lesson.topic.id,
                  lesson.subtopic.id,
                ),
              ),
            )
          else
            _AllDoneCard(
              title: l.allLessonsCompleteTitle,
              body: l.allLessonsCompleteBody,
            ),
          const SizedBox(height: AppConstants.spacingLg),
          Text(
            l.learningModules,
            style: BayanTypography.labelLarge.copyWith(
              color: BayanColors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          LearningModulesGrid(modules: modules),
          const SizedBox(height: AppConstants.spacingLg),
          WeeklyOverviewCard(
            words: 84,
            wordsGoal: 100,
            lessons: 15,
            lessonsGoal: 20,
            hours: 3.2,
            hoursGoal: 5,
            changePercent: 12,
          ),
        ],
      ),
    );
  }
}

class _AllDoneCard extends StatelessWidget {
  final String title;
  final String body;

  const _AllDoneCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: BayanColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: BayanColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: BayanTypography.titleLarge.copyWith(
                    color: BayanColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: BayanTypography.bodyMedium.copyWith(
                    color: BayanColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
