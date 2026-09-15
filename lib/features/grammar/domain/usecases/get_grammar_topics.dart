import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/grammar_topic.dart';
import '../repositories/grammar_repository.dart';

@injectable
class GetGrammarTopics {
  final GrammarRepository _repository;

  GetGrammarTopics(this._repository);

  Future<Either<AppException, List<GrammarTopic>>> execute({
    int? levelId,
  }) async {
    try {
      final result = levelId == null
          ? await _repository.getTopics()
          : await _repository.getTopicsForLevel(levelId);
      return Right(result);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
