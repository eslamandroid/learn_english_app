import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/sentence_item.dart';
import '../repositories/sentences_repository.dart';

@injectable
class GetSentences {
  final SentencesRepository _repository;
  GetSentences(this._repository);

  Future<Either<AppException, List<SentenceItem>>> execute({
    required int subtopicId,
  }) async {
    try {
      return Right(await _repository.getSentences(subtopicId));
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
