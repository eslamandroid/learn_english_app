import 'package:sqflite/sqflite.dart';

/// Single read point for all "explanation" text in content.
///
/// In v1.0 the only supported [currentLocale] is `'ar'` and all Arabic values
/// come directly from the Arabic columns in content.db.
/// In v1.2+, non-Arabic locales will look up rows from the `translation` table.
///
/// The field names passed to [localize] must match the column names in
/// content.db exactly — they become the key in the `translation` table.
abstract class ContentLocalizer {
  /// Current content explanation locale (e.g. `'ar'`). Always `'ar'` in v1.0.
  String get currentLocale;

  /// Must be called once at app boot after `@Named('user') Database` is ready.
  Future<void> bind(Database userDb);

  /// Returns the localised text for a content field.
  ///
  /// - [currentLocale] == `'ar'`: returns [arabicValue] when non-empty;
  ///   otherwise [englishValue].
  /// - Other locales: looks up `(sourceTable, sourceId, field, locale)` in the
  ///   in-memory translation cache; falls back to [englishValue] and logs a
  ///   `translation_missing` Analytics event.
  String localize({
    required String sourceTable,
    required int sourceId,
    required String field,
    required String englishValue,
    String? arabicValue,
  });
}
