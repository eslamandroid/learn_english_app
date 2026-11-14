import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../entities/conversation_category.dart';
import '../repositories/conversation_repository.dart';

@injectable
class GetConversationCategories {
  final ConversationRepository _repository;
  GetConversationCategories(this._repository);

  Future<Either<AppException, List<ConversationCategory>>> execute() async {
    try {
      return Right(await _repository.getCategories());
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
