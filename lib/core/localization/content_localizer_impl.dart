import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../database/user_db_schema.dart';
import 'content_localizer.dart';

/// Concrete singleton of [ContentLocalizer].
///
/// Mirrors the singleton pattern of [AppVoicePreferences] and
/// [AppContentLanguage]: call [bind] once at app boot (via `main.dart`
/// after DI resolves), then access [instance] from anywhere — including
/// from the static `fromMap` factories in data-layer models.
///
/// **[currentLocale] vs UI language:** [currentLocale] controls the language
/// of *content explanations*. It lives in `user_settings.explanation_locale`
/// and is entirely separate from `language_code` in SharedPreferences (which
/// is the UI / onboarding language). These two concepts must not be merged.
///
/// DI registration is done via [LocalizationModule] in `di/modules.dart`.
class ContentLocalizerImpl implements ContentLocalizer {
  ContentLocalizerImpl._();

  static final ContentLocalizerImpl instance = ContentLocalizerImpl._();

  String _locale = 'ar';

  // TODO(1.2): cache translation rows per locale at bind() time once the table
  // has data. Key: '$sourceTable/$sourceId/$field', Value: translated text.
  final Map<String, Map<String, String>> _translationCache = {};

  @override
  String get currentLocale => _locale;

  @override
  Future<void> bind(Database userDb) async {
    // Read stored explanation_locale — acknowledged but not acted on in v1.0.
    // Only 'ar' is supported; any other value (e.g. 'en' migrated from the
    // legacy `language_code` UI pref) is intentionally ignored here.
    // TODO(1.2): when Turkish is added, check stored value against a
    // supported-content-locales list before assigning it to _locale.
    await userDb.query(
      UserDbSchema.tUserSettings,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [UserDbSchema.keyExplanationLocale],
      limit: 1,
    );
    _locale = 'ar';
  }

  @override
  String localize({
    required String sourceTable,
    required int sourceId,
    required String field,
    required String englishValue,
    String? arabicValue,
  }) {
    if (_locale == 'ar') {
      final ar = arabicValue;
      if (ar != null && ar.isNotEmpty) return ar;
      return englishValue;
    }

    // Non-ar locale: check in-memory cache first (populated at bind() in 1.2+).
    final cacheKey = '$sourceTable/$sourceId/$field';
    final cached = _translationCache[_locale]?[cacheKey];
    if (cached != null) return cached;

    // Not in cache → log the gap and fall back to English.
    unawaited(_logMissingTranslation(
      sourceTable: sourceTable,
      sourceId: sourceId,
      field: field,
      locale: _locale,
    ));
    return englishValue;
  }

  // ── Test helpers ─────────────────────────────────────────────────────────

  /// Overrides [currentLocale] in tests. Not for production use.
  @visibleForTesting
  void debugSetLocale(String locale) => _locale = locale;

  /// Seeds a translation cache entry for unit tests. Not for production use.
  @visibleForTesting
  void debugAddTranslation({
    required String sourceTable,
    required int sourceId,
    required String field,
    required String locale,
    required String text,
  }) {
    final key = '$sourceTable/$sourceId/$field';
    (_translationCache[locale] ??= {})[key] = text;
  }

  /// Resets locale and cache to defaults — call in test [tearDown].
  @visibleForTesting
  void debugReset() {
    _locale = 'ar';
    _translationCache.clear();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _logMissingTranslation({
    required String sourceTable,
    required int sourceId,
    required String field,
    required String locale,
  }) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'translation_missing',
        parameters: {
          'source_table': sourceTable,
          'source_id': sourceId.toString(),
          'field': field,
          'locale': locale,
        },
      );
    } catch (_) {
      // Analytics failures must never surface to the user.
    }
  }
}
