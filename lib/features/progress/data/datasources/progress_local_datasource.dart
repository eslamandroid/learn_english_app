import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProgressLocalDataSource {
  // ─── Grammar (subtopics) ──────────────────────────────────────────────
  Future<Set<int>> getCompletedGrammarSubtopics();
  Future<int?> getInProgressGrammarSubtopic();
  Future<void> setInProgressGrammarSubtopic(int? id);
  Future<void> markGrammarSubtopicCompleted(int id);

  // ─── Phonetics (topics) ───────────────────────────────────────────────
  Future<Set<int>> getCompletedPhoneticTopics();
  Future<int?> getInProgressPhoneticTopic();
  Future<void> setInProgressPhoneticTopic(int? id);
  Future<void> markPhoneticTopicCompleted(int id);
}

@LazySingleton(as: ProgressLocalDataSource)
class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  final SharedPreferences _prefs;

  ProgressLocalDataSourceImpl(this._prefs);

  // Prefs keys ─ one pair per module so different modules can't collide.
  static const _kGrammarCompleted  = 'grammar.completed_subtopics';
  static const _kGrammarInProgress = 'grammar.in_progress_subtopic';
  static const _kPhoneticsCompleted  = 'phonetics.completed_topics';
  static const _kPhoneticsInProgress = 'phonetics.in_progress_topic';

  // ─── Generic helpers ──────────────────────────────────────────────────
  Set<int> _readSet(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return <int>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => e is int ? e : int.tryParse('$e') ?? -1)
            .where((e) => e >= 0)
            .toSet();
      }
    } catch (_) {
      // Corrupt payload — treat as empty.
    }
    return <int>{};
  }

  Future<void> _writeSet(String key, Set<int> ids) async {
    await _prefs.setString(key, jsonEncode(ids.toList()..sort()));
  }

  Future<void> _writeInt(String key, int? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setInt(key, value);
    }
  }

  // ─── Grammar implementations ──────────────────────────────────────────
  @override
  Future<Set<int>> getCompletedGrammarSubtopics() async =>
      _readSet(_kGrammarCompleted);

  @override
  Future<int?> getInProgressGrammarSubtopic() async =>
      _prefs.getInt(_kGrammarInProgress);

  @override
  Future<void> setInProgressGrammarSubtopic(int? id) =>
      _writeInt(_kGrammarInProgress, id);

  @override
  Future<void> markGrammarSubtopicCompleted(int id) async {
    final completed = _readSet(_kGrammarCompleted);
    completed.add(id);
    await _writeSet(_kGrammarCompleted, completed);
    if (await getInProgressGrammarSubtopic() == id) {
      await setInProgressGrammarSubtopic(null);
    }
  }

  // ─── Phonetics implementations ────────────────────────────────────────
  @override
  Future<Set<int>> getCompletedPhoneticTopics() async =>
      _readSet(_kPhoneticsCompleted);

  @override
  Future<int?> getInProgressPhoneticTopic() async =>
      _prefs.getInt(_kPhoneticsInProgress);

  @override
  Future<void> setInProgressPhoneticTopic(int? id) =>
      _writeInt(_kPhoneticsInProgress, id);

  @override
  Future<void> markPhoneticTopicCompleted(int id) async {
    final completed = _readSet(_kPhoneticsCompleted);
    completed.add(id);
    await _writeSet(_kPhoneticsCompleted, completed);
    if (await getInProgressPhoneticTopic() == id) {
      await setInProgressPhoneticTopic(null);
    }
  }
}
