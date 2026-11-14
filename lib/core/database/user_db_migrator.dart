import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'user_db_schema.dart';

class UserDbMigrator {
  UserDbMigrator._();

  static const _kGrammarCompleted = 'grammar.completed_subtopics';
  static const _kGrammarInProgress = 'grammar.in_progress_subtopic';
  static const _kPhoneticsCompleted = 'phonetics.completed_topics';
  static const _kPhoneticsInProgress = 'phonetics.in_progress_topic';

  static Future<void> runIfNeeded(
    SharedPreferences prefs,
    Database userDb,
  ) async {
    final done = await _getSetting(userDb, UserDbSchema.keyMigrationDone);
    if (done == '1') return;

    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      await userDb.transaction((txn) async {
        await _migrateProgress(
          txn: txn,
          prefs: prefs,
          completedKey: _kGrammarCompleted,
          inProgressKey: _kGrammarInProgress,
          sourceTable: UserDbSchema.srcGrammarSubTopics,
          now: now,
        );

        await _migrateProgress(
          txn: txn,
          prefs: prefs,
          completedKey: _kPhoneticsCompleted,
          inProgressKey: _kPhoneticsInProgress,
          sourceTable: UserDbSchema.srcPhoneticTopic,
          now: now,
        );

        final level = prefs.get('selected_level');
        if (level != null) {
          await _upsertSetting(txn, UserDbSchema.keyLevel, '$level');
        }

        final voice = prefs.getString('selected_voice');
        if (voice != null) {
          await _upsertSetting(txn, UserDbSchema.keyVoiceKey, voice);
        }

        final locale = prefs.getString('language_code');
        if (locale != null) {
          await _upsertSetting(
            txn,
            UserDbSchema.keyExplanationLocale,
            locale,
          );
        }

        await _upsertSetting(txn, UserDbSchema.keyMigrationDone, '1');
      });
    } catch (e, stack) {
      debugPrint('[UserDbMigrator] error: $e');
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stack,
          fatal: false,
          reason: 'UserDbMigrator.runIfNeeded',
        );
      }
      // Do NOT write migration_done — retry next launch.
    }
  }

  static Future<void> _migrateProgress({
    required DatabaseExecutor txn,
    required SharedPreferences prefs,
    required String completedKey,
    required String inProgressKey,
    required String sourceTable,
    required int now,
  }) async {
    final completedIds = _readIntList(prefs, completedKey);
    for (final id in completedIds) {
      await txn.insert(
        UserDbSchema.tUserProgress,
        {
          'source_table': sourceTable,
          'source_id': id,
          'status': UserDbSchema.statusCompleted,
          'attempts': 1,
          'completed_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    final inProgress = prefs.getInt(inProgressKey);
    if (inProgress != null && !completedIds.contains(inProgress)) {
      await txn.insert(
        UserDbSchema.tUserProgress,
        {
          'source_table': sourceTable,
          'source_id': inProgress,
          'status': UserDbSchema.statusInProgress,
          'started_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  static List<int> _readIntList(SharedPreferences prefs, String key) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => e is int ? e : int.tryParse('$e') ?? -1)
            .where((e) => e >= 0)
            .toList();
      }
    } catch (_) {
      // Corrupt payload — skip silently.
    }
    return [];
  }

  static Future<String?> _getSetting(Database db, String key) async {
    final rows = await db.query(
      UserDbSchema.tUserSettings,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  static Future<void> _upsertSetting(
    DatabaseExecutor txn,
    String key,
    String value,
  ) async {
    await txn.insert(
      UserDbSchema.tUserSettings,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
