import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_english_app/app/route/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../di/di.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/grammar/presentation/screens/grammar_lesson_screen.dart';
import '../../features/grammar/presentation/screens/grammar_test_screen.dart';
import '../../features/grammar/presentation/screens/grammar_topics_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/phonetics/presentation/screens/phonetics_categories_screen.dart';
import '../../features/phonetics/presentation/screens/phonetics_detail_screen.dart';
import '../../features/phonetics/presentation/screens/phonetics_topics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../constants/app_constants.dart';
import 'app_routes.dart';

abstract class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  // One navigator key per shell branch — go_router uses these to keep each
  // tab's navigation stack independent.
  static final _homeNavigatorKey = GlobalKey<NavigatorState>();
  static final _learnNavigatorKey = GlobalKey<NavigatorState>();
  static final _talkNavigatorKey = GlobalKey<NavigatorState>();
  static final _wordsNavigatorKey = GlobalKey<NavigatorState>();
  static final _profileNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (!getIt.isRegistered<SharedPreferences>()) return null;
      final prefs = getIt<SharedPreferences>();
      final isOnboarded =
          prefs.getBool(AppConstants.prefOnboardingComplete) ?? false;
      final goingToOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (!isOnboarded && !goingToOnboarding) return AppRoutes.onboarding;
      if (isOnboarded && goingToOnboarding) return AppRoutes.dashboard;
      return null;
    },
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
    routes: [
      // Onboarding sits OUTSIDE the shell — no bottom nav while onboarding.
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      GoRoute(
        path: AppRoutes.phonetics,
        name: 'phonetics',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PhoneticsCategoriesScreen(),
        routes: [
          GoRoute(
            path: ':catId',
            name: 'phoneticsTopics',
            builder: (context, state) => PhoneticsTopicsScreen(
              categoryId: int.parse(state.pathParameters['catId']!),
              categoryTitle: state.extra is String
                  ? state.extra as String
                  : null,
            ),
            routes: [
              GoRoute(
                path: ':topicId',
                name: 'phoneticsDetail',
                builder: (context, state) => PhoneticsDetailScreen(
                  topicId: int.parse(state.pathParameters['topicId']!),
                ),
              ),
            ],
          ),
        ],
      ),

      // Five-tab shell wrapping every primary destination. Each branch keeps
      // its own navigator stack so switching tabs preserves nested state.
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, shell) => MainShellScreen(shell: shell),
        branches: [
          // ── Home ─────────────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // ── Learn (phonetics + grammar + vocabulary + sentences) ─────────
          StatefulShellBranch(
            navigatorKey: _learnNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.grammar,
                name: 'grammar',
                builder: (context, state) => const GrammarTopicsScreen(),
                routes: [
                  GoRoute(
                    path: ':topicId/:subtopicId',
                    name: 'grammarLesson',
                    builder: (context, state) => GrammarLessonScreen(
                      subtopicId: int.parse(state.pathParameters['subtopicId']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'test',
                        name: 'grammarTest',
                        builder: (context, state) => GrammarTestScreen(
                          subtopicId:
                              int.parse(state.pathParameters['subtopicId']!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Talk (conversations) ─────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _talkNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.conversations,
                name: 'conversations',
                builder: (context, state) =>
                    const _PlaceholderScreen(label: 'Conversations'),
              ),
            ],
          ),

          // ── Words (word list) ────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _wordsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.wordList,
                name: 'wordList',
                builder: (context, state) =>
                    const _PlaceholderScreen(label: 'Word list'),
              ),
            ],
          ),

          // ── Profile (profile + settings) ─────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [

              GoRoute(
                path: AppRoutes.settings,
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text('$label screen — not yet implemented')),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final Exception? error;
  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error?.toString() ?? 'Unknown route error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
