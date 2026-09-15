import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:learn_english_app/base/base.dart';

import '../model/language_model.dart';
import '../repository/language_repository.dart';

@Injectable()
class GetSupportedLanguagesUsecase {
  final LanguageRepository _repository;

  GetSupportedLanguagesUsecase(this._repository);

  Either<AppException, List<LanguageModel>> execute() {
    try {
      final languages = _repository.getSupportedLanguages();
      return Right(languages);
    } catch (error) {
      return Left(error is AppException ? error : AppUncaughtException(error));
    }
  }
}

