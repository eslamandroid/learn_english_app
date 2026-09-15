import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/phonetic_topic.dart';
import '../repositories/phonetic_repository.dart';

@injectable
class GetPhoneticTopic {
  final PhoneticRepository _repository;

  GetPhoneticTopic(this._repository);

  Future<Either<AppException, PhoneticTopic?>> execute({
    required int id,
  }) async {
    try {
      final result = await _repository.getTopicById(id);
      return Right(result);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
