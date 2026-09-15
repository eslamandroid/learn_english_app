import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../base/errors/base/app_exception.dart';
import '../../base/errors/uncaught/app_uncaught_exception.dart';
import '../../shared/enums/cefr_level.dart';
import '../constants/app_constants.dart';

/// Persists the user's selected CEFR level. Pairs with [GetSelectedLevel].
///
/// Changing the level invalidates a lot of cached per-level content (grammar
/// topics, phonetic categories, dashboard stats). Call sites that drive the
/// settings change should follow the write with a full Phoenix restart so
/// every bloc reads the new level from scratch.
@injectable
class SetSelectedLevel {
  final SharedPreferences _prefs;

  SetSelectedLevel(this._prefs);

  Future<Either<AppException, Unit>> execute(CefrLevel level) async {
    try {
      await _prefs.setString(AppConstants.prefSelectedLevel, level.key);
      return const Right(unit);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
