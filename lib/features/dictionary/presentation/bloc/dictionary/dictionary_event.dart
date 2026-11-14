import 'package:equatable/equatable.dart';

import '../../../../../shared/enums/cefr_level.dart';
import '../../../domain/entities/dictionary_word.dart';

abstract class DictionaryEvent extends Equatable {
  const DictionaryEvent();
  @override
  List<Object?> get props => [];
}

/// Fired once when the screen mounts: load the first page and the saved set.
class LoadInitialDictionary extends DictionaryEvent {
  const LoadInitialDictionary();
}

/// Fired from the search bar after its own debounce — the bloc restarts
/// pagination from offset 0 for the new query.
class DictionaryQueryChanged extends DictionaryEvent {
  final String query;
  const DictionaryQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

/// Null [level] means "All" — removes the WHERE clause.
class DictionaryLevelChanged extends DictionaryEvent {
  final CefrLevel? level;
  const DictionaryLevelChanged(this.level);
  @override
  List<Object?> get props => [level];
}

/// User reached the end of the list — fetch the next page.
class DictionaryLoadMore extends DictionaryEvent {
  const DictionaryLoadMore();
}

/// Toggle a word in / out of My Words. Optimistic — the bloc flips `isSaved`
/// in local state immediately, then writes to the DB.
class DictionaryToggleSaved extends DictionaryEvent {
  final DictionaryWord word;
  const DictionaryToggleSaved(this.word);
  @override
  List<Object?> get props => [word.id, word.isSaved];
}

/// Tap on the audio button of a word row.
class DictionaryPlayAudio extends DictionaryEvent {
  final DictionaryWord word;
  const DictionaryPlayAudio(this.word);
  @override
  List<Object?> get props => [word.id];
}

class DictionaryStopAudio extends DictionaryEvent {
  const DictionaryStopAudio();
}

/// Internal — fires when the repository's `savedChanges` stream emits (so
/// edits made via the My Words sheet reflect back in the main list).
class DictionarySavedSetRefreshed extends DictionaryEvent {
  const DictionarySavedSetRefreshed();
}
