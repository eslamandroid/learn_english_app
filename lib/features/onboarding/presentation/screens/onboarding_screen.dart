import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../di/di.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../shared/enums/cefr_level.dart';
import '../bloc/onboarding_cubit.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/level_selection_card.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (prev, curr) =>
          prev.currentPage != curr.currentPage ||
          (!prev.isCompleted && curr.isCompleted),
      listener: (context, state) {
        if (state.isCompleted) {
          context.go(AppRoutes.dashboard);
          return;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            state.currentPage,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();
        final isLastPage = state.currentPage == OnboardingCubit.totalPages - 1;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _Header(currentPage: state.currentPage, onSkip: cubit.completeOnboarding),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: cubit.goToPage,
                    children: [
                      const OnboardingPage(
                        icon: Icons.translate_rounded,
                        title: 'Welcome to Bayan English',
                        description:
                            'Master English through phonetics, grammar, vocabulary, sentences, and conversations.',
                      ),
                      const OnboardingPage(
                        icon: Icons.headphones_rounded,
                        title: 'Listen to Native Voices',
                        description:
                            'Four professional voices in US & UK accents to train your ear.',
                      ),
                      _LevelSelectionPage(
                        selected: state.selectedLevel,
                        onSelect: cubit.selectLevel,
                      ),
                    ],
                  ),
                ),
                _Footer(
                  currentPage: state.currentPage,
                  isLastPage: isLastPage,
                  canFinish: state.selectedLevel != null,
                  onPrev: cubit.previousPage,
                  onNext: cubit.nextPage,
                  onFinish: cubit.completeOnboarding,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final int currentPage;
  final VoidCallback onSkip;

  const _Header({required this.currentPage, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.containerPadding,
        AppConstants.spacingSm,
        AppConstants.containerPadding,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(OnboardingCubit.totalPages, (i) {
              final isActive = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: AppConstants.spacingXs),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? BayanColors.primary
                      : BayanColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
              );
            }),
          ),
          TextButton(onPressed: onSkip, child: const Text('Skip')),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final int currentPage;
  final bool isLastPage;
  final bool canFinish;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const _Footer({
    required this.currentPage,
    required this.isLastPage,
    required this.canFinish,
    required this.onPrev,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.containerPadding),
      child: Row(
        children: [
          if (currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onPrev,
                child: const Text('Back'),
              ),
            ),
          if (currentPage > 0) const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed:
                  isLastPage ? (canFinish ? onFinish : null) : onNext,
              child: Text(isLastPage ? 'Get started' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelSelectionPage extends StatelessWidget {
  final CefrLevel? selected;
  final ValueChanged<CefrLevel> onSelect;

  const _LevelSelectionPage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.containerPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'Choose your level',
            style: BayanTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'We\'ll tailor your learning path.',
            style: BayanTypography.bodyMedium.copyWith(
              color: BayanColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingLg),
          ...CefrLevel.values.map(
            (level) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
              child: LevelSelectionCard(
                level: level,
                isSelected: selected == level,
                onTap: () => onSelect(level),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
