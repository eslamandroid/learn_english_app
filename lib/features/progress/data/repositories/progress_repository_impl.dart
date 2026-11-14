import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../domain/entities/conversation_progress.dart';
import '../../domain/entities/grammar_progress.dart';
import '../../domain/entities/phonetics_progress.dart';
import '../../domain/entities/sentence_lesson_progress.dart';
import '../../domain/entities/sentences_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';

@LazySingleton(as: ProgressRepository)
class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDataSource _local;

  final StreamController<void> _changes =
      StreamController<void>.broadcast();

  ProgressRepositoryImpl(this._local);

  @override
  Stream<void> get changes => _changes.stream;

  // ─── Grammar ──────────────────────────────────────────────────────────
  @override
  Future<GrammarProgress> getGrammarProgress() async {
    return GrammarProgress(
      completedSubtopicIds: await _local.getCompletedGrammarSubtopics(),
      inProgressSubtopicId: await _local.getInProgressGrammarSubtopic(),
    );
  }

  @override
  Future<void> markGrammarLessonStarted(int subtopicId) async {
    final completed = await _local.getCompletedGrammarSubtopics();
    if (completed.contains(subtopicId)) return;
    final existing = await _local.getInProgressGrammarSubtopic();
    if (existing == subtopicId) return;
    await _local.setInProgressGrammarSubtopic(subtopicId);
    _changes.add(null);
  }

  @override
  Future<void> markGrammarLessonCompleted(int subtopicId) async {
    final completed = await _local.getCompletedGrammarSubtopics();
    if (completed.contains(subtopicId)) return;
    await _local.markGrammarSubtopicCompleted(subtopicId);
    _changes.add(null);
  }

  // ─── Phonetics ────────────────────────────────────────────────────────
  @override
  Future<PhoneticsProgress> getPhoneticsProgress() async {
    return PhoneticsProgress(
      completedTopicIds: await _local.getCompletedPhoneticTopics(),
      inProgressTopicId: await _local.getInProgressPhoneticTopic(),
    );
  }

  @override
  Future<void> markPhoneticTopicStarted(int topicId) async {
    final completed = await _local.getCompletedPhoneticTopics();
    if (completed.contains(topicId)) return;
    final existing = await _local.getInProgressPhoneticTopic();
    if (existing == topicId) return;
    await _local.setInProgressPhoneticTopic(topicId);
    _changes.add(null);
  }

  @override
  Future<void> markPhoneticTopicCompleted(int topicId) async {
    final completed = await _local.getCompletedPhoneticTopics();
    if (completed.contains(topicId)) return;
    await _local.markPhoneticTopicCompleted(topicId);
    _changes.add(null);
  }

  // ─── Sentences ────────────────────────────────────────────────────────
  @override
  Future<SentencesProgress> getSentencesProgress() async {
    final rows = await _local.getSentenceLessonRows();
    return SentencesProgress(
      completedSubtopicIds: await _local.getCompletedSentencesSubtopics(),
      inProgressSubtopicId: await _local.getInProgressSentencesSubtopic(),
      lessons: {
        for (final r in rows.values)
          r.lessonId: SentenceLessonProgress(
            lessonId: r.lessonId,
            seen: r.seen,
            total: r.total,
            completedAt: DateTime.tryParse(r.completedAt ?? ''),
          ),
      },
    );
  }

  @override
  Future<void> markSentencesSubtopicStarted(int subtopicId) async {
    final completed = await _local.getCompletedSentencesSubtopics();
    if (completed.contains(subtopicId)) return;
    final existing = await _local.getInProgressSentencesSubtopic();
    if (existing == subtopicId) return;
    await _local.setInProgressSentencesSubtopic(subtopicId);
    _changes.add(null);
  }

  @override
  Future<void> markSentencesSubtopicCompleted(int subtopicId) async {
    final completed = await _local.getCompletedSentencesSubtopics();
    final rows = await _local.getSentenceLessonRows();
    final total = rows[subtopicId]?.total ?? 0;
    if (!completed.contains(subtopicId)) {
      await _local.markSentencesSubtopicCompleted(subtopicId);
    }
    await _local.markSentenceLessonCompleted(
      lessonId: subtopicId,
      total: total,
    );
    _changes.add(null);
  }

  @override
  Future<void> recordSentenceSeen({
    required int lessonId,
    required int seen,
    required int total,
  }) async {
    await _local.recordSentenceLessonSeen(
      lessonId: lessonId,
      seen: seen,
      total: total,
    );
    _changes.add(null);
  }

  // ─── Conversation ────────────────────────────────────────────────────
  @override
  Future<ConversationProgress> getConversationProgress() async {
    return ConversationProgress(
      completedLessonIds: await _local.getCompletedConversationLessons(),
      inProgressLessonId: await _local.getInProgressConversationLesson(),
    );
  }

  @override
  Future<void> markConversationLessonStarted(int lessonId) async {
    final completed = await _local.getCompletedConversationLessons();
    if (completed.contains(lessonId)) return;
    final existing = await _local.getInProgressConversationLesson();
    if (existing == lessonId) return;
    await _local.setInProgressConversationLesson(lessonId);
    _changes.add(null);
  }

  @override
  Future<void> markConversationLessonCompleted(int lessonId) async {
    final completed = await _local.getCompletedConversationLessons();
    if (completed.contains(lessonId)) return;
    await _local.markConversationLessonCompleted(lessonId);
    _changes.add(null);
  }

  @override
  @disposeMethod
  Future<void> dispose() => _changes.close();
}
