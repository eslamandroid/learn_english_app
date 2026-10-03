import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/sentence_subtopic.dart';
import '../repositories/sentences_repository.dart';

/// Returns every sentence subtopic in the catalog in a single query.
/// Used by the redesigned topics screen to render each topic's lesson
/// sublist without a per-topic round trip.
@injectable
class GetAllSentenceSubtopics {
  final SentencesRepository _repository;
  GetAllSentenceSubtopics(this._repository);

  Future<Either<AppException, List<SentenceSubtopic>>> execute() async {
    try {
      return Right(await _repository.getAllSubtopics());
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
