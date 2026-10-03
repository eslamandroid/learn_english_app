import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/dictionary_word.dart';
import '../repositories/dictionary_repository.dart';

@injectable
class GetMyWords {
  final DictionaryRepository _repository;
  GetMyWords(this._repository);

  Future<Either<AppException, List<DictionaryWord>>> execute() async {
    try {
      return Right(await _repository.getMyWords());
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }

  Stream<List<DictionaryWord>> watch() async* {
    yield await _repository.getMyWords();
    await for (final _ in _repository.savedChanges) {
      yield await _repository.getMyWords();
    }
  }
}
