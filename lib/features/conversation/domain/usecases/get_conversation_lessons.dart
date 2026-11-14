import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/conversation_lesson.dart';
import '../repositories/conversation_repository.dart';

@injectable
class GetConversationLessons {
  final ConversationRepository _repository;
  GetConversationLessons(this._repository);

  Future<Either<AppException, List<ConversationLesson>>> execute({
    required int categoryId,
  }) async {
    try {
      return Right(await _repository.getLessons(categoryId));
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
