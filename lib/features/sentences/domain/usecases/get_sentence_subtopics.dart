import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/sentence_subtopic.dart';
import '../repositories/sentences_repository.dart';

@injectable
class GetSentenceSubtopics {
  final SentencesRepository _repository;
  GetSentenceSubtopics(this._repository);

  Future<Either<AppException, List<SentenceSubtopic>>> execute({
    required int topicId,
  }) async {
    try {
      return Right(await _repository.getSubtopics(topicId));
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
