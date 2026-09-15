import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:learn_english_app/base/base.dart';

import '../repository/language_repository.dart';

@Injectable()
class ChangeLanguageUsecase {
  final LanguageRepository _repository;

  ChangeLanguageUsecase(this._repository);

  Future<Either<AppException, bool>> execute(String languageCode) async {
    try {
      final result = await _repository.changeLanguage(languageCode);
      return Right(result);
    } catch (error) {
      return Left(error is AppException ? error : AppUncaughtException(error));
    }
  }
}

