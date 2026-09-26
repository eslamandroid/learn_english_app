import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/vocabulary_word.dart';
import '../repositories/vocabulary_repository.dart';

@injectable
class GetVocabularyWords {
  final VocabularyRepository _repository;

  GetVocabularyWords(this._repository);

  Future<Either<AppException, List<VocabularyWord>>> execute({
    required int subtopicId,
  }) async {
    try {
      final result = await _repository.getWords(subtopicId);
      return Right(result);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
