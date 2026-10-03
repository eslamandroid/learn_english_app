import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/sentence_topic.dart';
import '../repositories/sentences_repository.dart';

@injectable
class GetSentenceTopics {
  final SentencesRepository _repository;
  GetSentenceTopics(this._repository);

  Future<Either<AppException, List<SentenceTopic>>> execute() async {
    try {
      return Right(await _repository.getTopics());
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
