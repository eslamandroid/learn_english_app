import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/enums/cefr_level.dart';
import '../models/dashboard_stats_model.dart';

abstract class DashboardLocalDataSource {
  Future<DashboardStatsModel> getStats();
}

@LazySingleton(as: DashboardLocalDataSource)
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final SharedPreferences _prefs;

  DashboardLocalDataSourceImpl(this._prefs);

  static const _kLongestStreak  = 'longest_streak';
  static const _kTotalXp        = 'total_xp';
  static const _kDailyCompleted = 'daily_completed';
  static const _kDailyGoal      = 'daily_goal';

  @override
  Future<DashboardStatsModel> getStats() async {
    final levelKey = _prefs.getString(AppConstants.prefSelectedLevel);
    final level = CefrLevel.fromKey(levelKey);

    final streak  = _prefs.getInt(AppConstants.prefStreakCount) ?? 0;
    final longest = _prefs.getInt(_kLongestStreak) ?? streak;
    final daily   = _prefs.getInt(_kDailyCompleted) ?? 0;
    final goal    = _prefs.getInt(_kDailyGoal) ?? 6;
    final xp      = _prefs.getInt(_kTotalXp) ?? 0;

    return DashboardStatsModel(
      currentStreak: streak,
      longestStreak: longest,
      dailyCompleted: daily,
      dailyGoal: goal,
      totalXp: xp,
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
}
