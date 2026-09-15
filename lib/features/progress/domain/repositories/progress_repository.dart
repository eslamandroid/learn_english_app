import '../entities/grammar_progress.dart';
import '../entities/phonetics_progress.dart';

abstract class ProgressRepository {
  // ─── Grammar ──────────────────────────────────────────────────────────
  Future<GrammarProgress> getGrammarProgress();
  Future<void> markGrammarLessonStarted(int subtopicId);
  Future<void> markGrammarLessonCompleted(int subtopicId);

  // ─── Phonetics ────────────────────────────────────────────────────────
  Future<PhoneticsProgress> getPhoneticsProgress();
  Future<void> markPhoneticTopicStarted(int topicId);
  Future<void> markPhoneticTopicCompleted(int topicId);

  /// Broadcasts every write across every module. Subscribers (blocs) typically
  /// re-fetch the snapshot(s) they care about on each event.
  Stream<void> get changes;
}
