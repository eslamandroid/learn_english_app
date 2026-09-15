import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/grammar_rule_test.dart';
import '../repositories/grammar_repository.dart';

@injectable
class GetGrammarRuleTests {
  final GrammarRepository _repository;

  GetGrammarRuleTests(this._repository);

  Future<Either<AppException, List<GrammarRuleTest>>> execute({
    required int subtopicId,
  }) async {
    try {
      final result = await _repository.getRuleTests(subtopicId);
      return Right(result);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
