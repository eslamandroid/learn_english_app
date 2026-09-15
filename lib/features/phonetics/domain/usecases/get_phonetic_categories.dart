import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/phonetic_category.dart';
import '../repositories/phonetic_repository.dart';

@injectable
class GetPhoneticCategories {
  final PhoneticRepository _repository;

  GetPhoneticCategories(this._repository);

  Future<Either<AppException, List<PhoneticCategory>>> execute() async {
    try {
      final result = await _repository.getCategories();
      return Right(result);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
