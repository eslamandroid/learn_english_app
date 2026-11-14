import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/conversation_line.dart';
import '../repositories/conversation_repository.dart';

@injectable
class GetConversationLines {
  final ConversationRepository _repository;
  GetConversationLines(this._repository);

  Future<Either<AppException, List<ConversationLine>>> execute({
    required int lessonId,
  }) async {
    try {
      return Right(await _repository.getLines(lessonId));
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
