import '../../../../core/localization/content_localizer_impl.dart';
import '../../../../shared/enums/cefr_level.dart';
import '../../domain/entities/dictionary_word.dart';

class DictionaryWordModel extends DictionaryWord {
  const DictionaryWordModel({
    required super.id,
    required super.word,
    required super.arabic,
    required super.pronunciation,
    required super.example,
    required super.level,
    required super.isSaved,
  });

  /// Builds a word model from a `word_list` row. [isSaved] comes from the
  /// user DB (see [MyWordsLocalDataSource.getSavedWordsLower]) and is passed
  /// in — not inferred from the content row.
  factory DictionaryWordModel.fromMap(
    Map<String, Object?> map, {
    required bool isSaved,
  }) {
    final id = map['id'] as int;
    final english = map['word'] as String;
    return DictionaryWordModel(
      id: id,
      word: english,
      arabic: ContentLocalizerImpl.instance.localize(
        sourceTable: 'word_list',
        sourceId: id,
        field: 'word_ar',
        englishValue: english,
        arabicValue: map['word_ar'] as String?,
      ),
      pronunciation: (map['pronunciation'] as String?) ?? '',
      example: (map['example'] as String?) ?? '',
      // DB stores 'A1'..'C2' — enum keys are lowercase.
      level: CefrLevel.fromKey((map['level'] as String).toLowerCase()),
      isSaved: isSaved,
    );
  }

  /// Rebuilds a model from a `my_word_list` row for the My Words sheet. Since
  /// the user DB only persists the English + translation, we fill the other
  /// fields from the matching `word_list` row the repository joined for us.
  /// `isSaved` is trivially true here.
  factory DictionaryWordModel.fromMyWordsJoin({
    required Map<String, Object?> myWordRow,
    required Map<String, Object?>? wordListRow,
  }) {
    if (wordListRow != null) {
      return DictionaryWordModel.fromMap(wordListRow, isSaved: true);
    }
    // Orphan save (the word_list row was removed in a later content update
    // but the user still has it in their list) — fall back to just the fields
    // user.db knows about so we never throw.
    return DictionaryWordModel(
      id: (myWordRow['source_id'] as int?) ?? 0,
      word: myWordRow['word'] as String,
      arabic: (myWordRow['translation'] as String?) ?? '',
      pronunciation: '',
      example: '',
      level: CefrLevel.a1,
      isSaved: true,
    );
  }
}
