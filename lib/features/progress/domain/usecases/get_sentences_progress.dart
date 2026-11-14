import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/sentences_progress.dart';
import '../repositories/progress_repository.dart';

@injectable
class GetSentencesProgress {
  final ProgressRepository _repository;
  GetSentencesProgress(this._repository);

  Future<Either<AppException, SentencesProgress>> execute() async {
    try {
      return Right(await _repository.getSentencesProgress());
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }

  Stream<SentencesProgress> watch() async* {
    yield await _repository.getSentencesProgress();
    await for (final _ in _repository.changes) {
      yield await _repository.getSentencesProgress();
    }
  }
}
