import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/phonetic_topic.dart';
import '../repositories/phonetic_repository.dart';

@injectable
class GetPhoneticTopics {
  final PhoneticRepository _repository;

  GetPhoneticTopics(this._repository);

  Future<Either<AppException, List<PhoneticTopic>>> execute({
    required int categoryId,
  }) async {
    try {
      final result = await _repository.getTopicsByCategory(categoryId);
      return Right(result);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
