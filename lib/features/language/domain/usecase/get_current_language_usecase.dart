import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:learn_english_app/base/base.dart';

import '../model/language_model.dart';
import '../repository/language_repository.dart';

@Injectable()
class GetCurrentLanguageUsecase {
  final LanguageRepository _repository;

  GetCurrentLanguageUsecase(this._repository);

  Future<Either<AppException, LanguageModel>> execute() async {
    try {
      final language = await _repository.getCurrentLanguage();
      return Right(language);
    } catch (error) {
      return Left(error is AppException ? error : AppUncaughtException(error));
    }
  }
}

