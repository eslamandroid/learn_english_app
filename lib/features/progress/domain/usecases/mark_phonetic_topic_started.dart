import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../repositories/progress_repository.dart';

@injectable
class MarkPhoneticTopicStarted {
  final ProgressRepository _repository;

  MarkPhoneticTopicStarted(this._repository);

  Future<Either<AppException, void>> execute({required int topicId}) async {
    try {
      await _repository.markPhoneticTopicStarted(topicId);
      return const Right(null);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
