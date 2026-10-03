import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/dictionary_word.dart';
import '../repositories/dictionary_repository.dart';

@injectable
class SaveWordToMyWords {
  final DictionaryRepository _repository;
  SaveWordToMyWords(this._repository);

  Future<Either<AppException, void>> execute(DictionaryWord word) async {
    try {
      await _repository.saveWord(word);
      return const Right(null);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
