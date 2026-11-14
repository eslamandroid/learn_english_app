import '../entities/conversation_progress.dart';
import '../entities/grammar_progress.dart';
import '../entities/phonetics_progress.dart';
import '../entities/sentences_progress.dart';

abstract class ProgressRepository {
  // ─── Grammar ──────────────────────────────────────────────────────────
  Future<GrammarProgress> getGrammarProgress();
  Future<void> markGrammarLessonStarted(int subtopicId);
  Future<void> markGrammarLessonCompleted(int subtopicId);

  // ─── Phonetics ────────────────────────────────────────────────────────
  Future<PhoneticsProgress> getPhoneticsProgress();
  Future<void> markPhoneticTopicStarted(int topicId);
  Future<void> markPhoneticTopicCompleted(int topicId);

  // ─── Sentences ────────────────────────────────────────────────────────
  Future<SentencesProgress> getSentencesProgress();
  Future<void> markSentencesSubtopicStarted(int subtopicId);
  Future<void> markSentencesSubtopicCompleted(int subtopicId);

  /// Record that the user has viewed up to card #[seen] of [total] in a
  /// lesson. Writes to `sentence_lesson_progress`; monotonic in [seen].
  Future<void> recordSentenceSeen({
    required int lessonId,
    required int seen,
    required int total,
  });

  // ─── Conversation ────────────────────────────────────────────────────
  Future<ConversationProgress> getConversationProgress();
  Future<void> markConversationLessonStarted(int lessonId);
  Future<void> markConversationLessonCompleted(int lessonId);

  /// Broadcasts every write across every module. Subscribers (blocs) typically
  /// re-fetch the snapshot(s) they care about on each event.
  Stream<void> get changes;

  Future<void> dispose();
}
