import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../repositories/progress_repository.dart';

/// Bumps `sentence_lesson_progress.seen` for [lessonId] (monotonic). Called
/// from the lesson screen as the user swipes through cards or scrolls past
/// a sentence in list mode, to drive the topic sublist's "9 / 16" state.
@injectable
class RecordSentenceSeen {
  final ProgressRepository _repository;
  RecordSentenceSeen(this._repository);

  Future<Either<AppException, void>> execute({
    required int lessonId,
    required int seen,
    required int total,
  }) async {
    try {
      await _repository.recordSentenceSeen(
        lessonId: lessonId,
        seen: seen,
        total: total,
      );
      return const Right(null);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}
