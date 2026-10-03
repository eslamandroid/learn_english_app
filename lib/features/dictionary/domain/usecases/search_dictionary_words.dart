import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../../../../shared/enums/cefr_level.dart';
import '../entities/dictionary_word.dart';
import '../repositories/dictionary_repository.dart';

@injectable
class SearchDictionaryWords {
  final DictionaryRepository _repository;
  SearchDictionaryWords(this._repository);

  Future<Either<AppException, List<DictionaryWord>>> execute({
    String? query,
    CefrLevel? level,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final results = await _repository.search(
        query: query,
        level: level,
        limit: limit,
        offset: offset,
      );
      return Right(results);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
