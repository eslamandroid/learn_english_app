import '../../../../shared/enums/cefr_level.dart';
import '../entities/dictionary_word.dart';

abstract class DictionaryRepository {
  /// Full-text search over `word_list.word` + `word_list.word_ar`.
  /// [query] null/empty → unfiltered. [level] null → all levels.
  /// Pagination via [limit]/[offset]; results merged with the user's saved
  /// set so each row knows its [DictionaryWord.isSaved] state.
  Future<List<DictionaryWord>> search({
    String? query,
    CefrLevel? level,
    int limit = 50,
    int offset = 0,
  });

  /// Every row currently in `my_word_list`, newest first.
  Future<List<DictionaryWord>> getMyWords();

  /// Saves [word] in `my_word_list` (`INSERT OR IGNORE` — safe to call twice).
  Future<void> saveWord(DictionaryWord word);

  /// Removes [word] by its spelling (NOCASE match — matches the UNIQUE index
  /// on `my_word_list.word`).
  Future<void> removeWord(String word);

  /// Fires every write to `my_word_list` so bloc subscribers can refresh their
  /// snapshot without polling. Decoupled from the generic progress stream.
  Stream<void> get savedChanges;

  Future<void> dispose();
}
