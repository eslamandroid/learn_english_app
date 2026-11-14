import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/arabic_visibility.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../bloc/conversation_categories/conversation_categories_bloc.dart';
import '../bloc/conversation_categories/conversation_categories_event.dart';
import '../bloc/conversation_categories/conversation_categories_state.dart';

class ConversationCategoriesScreen extends StatelessWidget {
  const ConversationCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConversationCategoriesBloc>()
        ..add(const LoadConversationCategories()),
      child: Scaffold(
        backgroundColor: BayanColors.screenBg,
        appBar: AppBar(
          backgroundColor: BayanColors.screenBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleSpacing: 16,
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
                'Conversations',
                style: BayanTypography.titleLarge.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: BayanColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        body: BlocBuilder<ConversationCategoriesBloc,
            ConversationCategoriesState>(
          builder: (context, state) {
            final bloc = context.read<ConversationCategoriesBloc>();
            return switch (state) {
              ConversationCategoriesInitial() ||
              ConversationCategoriesLoading() =>
                const Center(child: CircularProgressIndicator()),
              ConversationCategoriesError(:final message) => ErrorStateView(
                  message: message,
                  onRetry: () =>
                      bloc.add(const LoadConversationCategories()),
                ),
              ConversationCategoriesLoaded(:final categories) =>
                ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final c = categories[i];
                    return _CategoryCard(
                      title: c.title,
                      titleAr: c.titleAr,
                      lessonCount: c.lessonCount,
                      onTap: () => context.push(
                        AppRoutes.conversationLessons(c.id),
                        extra: c.title,
                      ),
                    );
                  },
                ),
            };
          },
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String titleAr;
  final int lessonCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.titleAr,
    required this.lessonCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BayanColors.cardBg,
      borderRadius: BorderRadius.circular(22),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: BayanColors.cardBg,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: BayanColors.onSurface.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: BayanColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_bubble_rounded,
                    color: BayanColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: BayanTypography.titleLarge.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: BayanColors.onSurface,
                      ),
                    ),
                    ArabicVisibility(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          titleAr,
                          style: BayanTypography.bodySmall.copyWith(
                            fontFamily: BayanTypography.arabicFontFamily,
                            color: BayanColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$lessonCount lessons',
                      style: BayanTypography.bodySmall.copyWith(
                        color: BayanColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: BayanColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
