import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/grammar_subtopic.dart';
import '../repositories/grammar_repository.dart';

@injectable
class GetGrammarSubtopics {
  final GrammarRepository _repository;

  GetGrammarSubtopics(this._repository);

  Future<Either<AppException, List<GrammarSubtopic>>> execute({
    required int topicId,
  }) async {
    try {
      final result = await _repository.getSubtopics(topicId);
      return Right(result);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
