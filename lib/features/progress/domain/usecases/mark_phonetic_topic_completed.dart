import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../repositories/progress_repository.dart';

@injectable
class MarkPhoneticTopicCompleted {
  final ProgressRepository _repository;

  MarkPhoneticTopicCompleted(this._repository);

  Future<Either<AppException, void>> execute({required int topicId}) async {
    try {
      await _repository.markPhoneticTopicCompleted(topicId);
      return const Right(null);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
