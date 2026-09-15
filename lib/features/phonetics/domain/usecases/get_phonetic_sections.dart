import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/phonetic_section.dart';
import '../repositories/phonetic_repository.dart';

@injectable
class GetPhoneticSections {
  final PhoneticRepository _repository;

  GetPhoneticSections(this._repository);

  Future<Either<AppException, List<PhoneticSection>>> execute({
    required int topicId,
    required String accent,
  }) async {
    try {
      final result = await _repository.getSections(
        topicId: topicId,
        accent: accent,
      );
      return Right(result);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
