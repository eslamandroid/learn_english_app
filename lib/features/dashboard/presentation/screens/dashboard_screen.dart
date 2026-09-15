import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_loaded_body.dart';
import '../widgets/dashboard_top_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardBloc>()..add(const LoadDashboard()),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final bloc = context.read<DashboardBloc>();
          final loaded = state is DashboardLoaded ? state : null;

          // TODO(profile): replace with the real user name from a future
          // ProfileBloc / GetUserProfile usecase. Placeholder for now.
          const userName = 'Omar';

          return Scaffold(
            backgroundColor: BayanColors.background,
            appBar: DashboardTopBar(
              level: loaded?.stats.currentLevel ?? bloc.fallbackLevel,
              streakDays: loaded?.stats.currentStreak ?? 0,
              onAvatarTap: () => context.go(AppRoutes.profile),
            ),
            body: switch (state) {
              DashboardInitial() ||
              DashboardLoading() =>
                const Center(child: CircularProgressIndicator()),
              DashboardError(:final message) => ErrorStateView(
                  message: message,
                  onRetry: () => bloc.add(const LoadDashboard()),
                ),
              DashboardLoaded(
                :final stats,
                :final currentGrammarLesson,
              ) =>
                RefreshIndicator(
                  onRefresh: () async =>
                      bloc.add(const RefreshDashboard()),
                  child: DashboardLoadedBody(
                    stats: stats,
                    userName: userName,
                    currentLesson: currentGrammarLesson,
                  ),
                ),
              _ => const SizedBox.shrink(),
            },
          );
        },
      ),
    );
  }
}
