import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../base/errors/base/app_exception.dart';
import '../../../../base/errors/uncaught/app_uncaught_exception.dart';
import '../../../grammar/domain/repositories/grammar_repository.dart';
import '../entities/current_grammar_lesson.dart';
import '../repositories/progress_repository.dart';

/// Resolves which grammar lesson the user should resume next:
///   1. The lesson currently marked in-progress (most recently opened, not
///      yet finished), or
///   2. The first uncompleted lesson scanning topics in order, then their
///      subtopics in order.
/// Returns `null` when every lesson is done.
@injectable
class GetCurrentGrammarLesson {
  final ProgressRepository _progressRepo;
  final GrammarRepository _grammarRepo;

  GetCurrentGrammarLesson(this._progressRepo, this._grammarRepo);

  Future<Either<AppException, CurrentGrammarLesson?>> execute() async {
    try {
      final progress = await _progressRepo.getGrammarProgress();
      final topics = await _grammarRepo.getTopics();

      // 1) In-progress wins if present.
      final inProgressId = progress.inProgressSubtopicId;
      if (inProgressId != null && !progress.isCompleted(inProgressId)) {
        for (final topic in topics) {
          final subs = await _grammarRepo.getSubtopics(topic.id);
          final match = subs.where((s) => s.id == inProgressId).firstOrNull;
          if (match != null) {
            return Right(CurrentGrammarLesson(
              topic: topic,
              subtopic: match,
              topicProgress:
                  progress.topicProgress(subs.map((s) => s.id).toList()),
            ));
          }
        }
      }

      // 2) Otherwise, first uncompleted lesson in document order.
      for (final topic in topics) {
        final subs = await _grammarRepo.getSubtopics(topic.id);
        for (final st in subs) {
          if (!progress.isCompleted(st.id)) {
            return Right(CurrentGrammarLesson(
              topic: topic,
              subtopic: st,
              topicProgress:
                  progress.topicProgress(subs.map((s) => s.id).toList()),
            ));
          }
        }
      }

      // Everything is done.
      return const Right(null);
    } catch (e) {
      return Left(e is AppException ? e : AppUncaughtException(e));
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
