import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/conversation_progress.dart';
import '../repositories/progress_repository.dart';

@injectable
class GetConversationProgress {
  final ProgressRepository _repository;
  GetConversationProgress(this._repository);

  Future<Either<AppException, ConversationProgress>> execute() async {
    try {
      return Right(await _repository.getConversationProgress());
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }

  Stream<ConversationProgress> watch() async* {
    yield await _repository.getConversationProgress();
    await for (final _ in _repository.changes) {
      yield await _repository.getConversationProgress();
    }
  }
}
