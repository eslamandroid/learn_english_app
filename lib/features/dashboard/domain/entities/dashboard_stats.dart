import 'package:equatable/equatable.dart';

import '../../../../shared/enums/cefr_level.dart';

class DashboardStats extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final int dailyCompleted;
  final int dailyGoal;
  final int totalXp;
  final CefrLevel currentLevel;
  final Map<String, double> moduleProgress;

  const DashboardStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.dailyCompleted,
    required this.dailyGoal,
    required this.totalXp,
    required this.currentLevel,
    required this.moduleProgress,
  });

  double get dailyProgress =>
      dailyGoal == 0 ? 0.0 : (dailyCompleted / dailyGoal).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        dailyCompleted,
        dailyGoal,
        totalXp,
        currentLevel,
        moduleProgress,
      ];
}
