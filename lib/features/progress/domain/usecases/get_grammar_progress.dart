import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/grammar_progress.dart';
import '../repositories/progress_repository.dart';

@injectable
class GetGrammarProgress {
  final ProgressRepository _repository;

  GetGrammarProgress(this._repository);

  Future<Either<AppException, GrammarProgress>> execute() async {
    try {
      return Right(await _repository.getGrammarProgress());
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }

  /// Live stream of progress snapshots — emits once on subscribe with the
  /// current value, then again on every write.
  Stream<GrammarProgress> watch() async* {
    yield await _repository.getGrammarProgress();
    await for (final _ in _repository.changes) {
      yield await _repository.getGrammarProgress();
    }
  }
}
