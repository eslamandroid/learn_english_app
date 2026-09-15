import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/grammar_lesson.dart';
import '../repositories/grammar_repository.dart';

@injectable
class GetGrammarLesson {
  final GrammarRepository _repository;

  GetGrammarLesson(this._repository);

  Future<Either<AppException, GrammarLesson?>> execute({
    required int subtopicId,
  }) async {
    try {
      final result = await _repository.getLesson(subtopicId);
      return Right(result);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
