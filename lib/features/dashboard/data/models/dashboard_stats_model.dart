import '../../../../shared/enums/cefr_level.dart';
import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.currentStreak,
    required super.longestStreak,
    required super.dailyCompleted,
    required super.dailyGoal,
    required super.totalXp,
    required super.currentLevel,
    required super.moduleProgress,
  });

  factory DashboardStatsModel.empty(CefrLevel level) => DashboardStatsModel(
        currentStreak: 0,
        longestStreak: 0,
        dailyCompleted: 0,
        dailyGoal: 6,
        totalXp: 0,
        currentLevel: level,
        moduleProgress: const {
          'phonetics': 0.0,
          'grammar': 0.0,
          'vocabulary': 0.0,
          'sentences': 0.0,
          'conversations': 0.0,
          'word_list': 0.0,
        },
      );
}
