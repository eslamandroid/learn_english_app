import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../repositories/dictionary_repository.dart';

@injectable
class RemoveWordFromMyWords {
  final DictionaryRepository _repository;
  RemoveWordFromMyWords(this._repository);

  Future<Either<AppException, void>> execute(String word) async {
    try {
      await _repository.removeWord(word);
      return const Right(null);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
