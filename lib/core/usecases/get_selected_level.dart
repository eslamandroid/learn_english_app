import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../base/errors/base/app_exception.dart';
import '../../base/errors/uncaught/app_uncaught_exception.dart';
import '../../shared/enums/cefr_level.dart';
import '../constants/app_constants.dart';

/// Cross-cutting use case for "what's the user's current CEFR level?".
///
/// Screens MUST NOT read `SharedPreferences` directly — they should depend on a
/// bloc that depends on this use case. The bloc decides whether to consume the
/// sync [current] (when level is needed at construction time, e.g. for an
/// AppBar pill) or the async [execute] (when following the project's
/// `Either<AppException, T>` convention for use cases).
@injectable
class GetSelectedLevel {
  final SharedPreferences _prefs;

  GetSelectedLevel(this._prefs);

  /// Synchronous read — safe because [SharedPreferences] is `@preResolve`d at
  /// app boot. Use this when a value is needed at bloc construction time.
  CefrLevel current() =>
      CefrLevel.fromKey(_prefs.getString(AppConstants.prefSelectedLevel));

  /// Convention-matching async wrapper (mirrors every other use case in the
  /// project). Always succeeds — the prefs read can't fail in practice — but
  /// the Either<> shape keeps call sites uniform.
  Future<Either<AppException, CefrLevel>> execute() async {
    try {
      return Right(current());
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
