import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../domain/entities/grammar_progress.dart';
import '../../domain/entities/phonetics_progress.dart';
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

  @disposeMethod
  Future<void> dispose() => _changes.close();
}
