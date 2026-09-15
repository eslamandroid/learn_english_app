import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/phonetics_progress.dart';
import '../repositories/progress_repository.dart';

@injectable
class GetPhoneticsProgress {
  final ProgressRepository _repository;

  GetPhoneticsProgress(this._repository);

  Future<Either<AppException, PhoneticsProgress>> execute() async {
    try {
      return Right(await _repository.getPhoneticsProgress());
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }

  /// Live snapshot stream — emits once on subscribe with the current value,
  /// then again on every write across any module.
  Stream<PhoneticsProgress> watch() async* {
    yield await _repository.getPhoneticsProgress();
    await for (final _ in _repository.changes) {
      yield await _repository.getPhoneticsProgress();
    }
  }
}
