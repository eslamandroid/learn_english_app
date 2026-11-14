import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../repositories/progress_repository.dart';

@injectable
class MarkConversationLessonCompleted {
  final ProgressRepository _repository;
  MarkConversationLessonCompleted(this._repository);

  Future<Either<AppException, void>> execute({required int lessonId}) async {
    try {
      await _repository.markConversationLessonCompleted(lessonId);
      return const Right(null);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
