import 'package:equatable/equatable.dart';

import '../../../../../shared/enums/cefr_level.dart';
import '../../../domain/entities/dictionary_word.dart';

enum DictionaryStatus { initial, loading, loaded, loadingMore, error }

class DictionaryState extends Equatable {
  final DictionaryStatus status;
  final List<DictionaryWord> words;
  final String query;
  final CefrLevel? level;
  final bool hasMore;
  final int? playingWordId;
  final int myWordsCount;
  final String? errorMessage;

  const DictionaryState({
    this.status = DictionaryStatus.initial,
    this.words = const [],
    this.query = '',
    this.level,
    this.hasMore = true,
    this.playingWordId,
    this.myWordsCount = 0,
    this.errorMessage,
  });

  bool get isSearching => query.trim().isNotEmpty || level != null;

  DictionaryState copyWith({
    DictionaryStatus? status,
    List<DictionaryWord>? words,
    String? query,
    CefrLevel? level,
    bool clearLevel = false,
    bool? hasMore,
    int? playingWordId,
    bool clearPlaying = false,
    int? myWordsCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DictionaryState(
      status: status ?? this.status,
      words: words ?? this.words,
      query: query ?? this.query,
      level: clearLevel ? null : (level ?? this.level),
      hasMore: hasMore ?? this.hasMore,
      playingWordId:
          clearPlaying ? null : (playingWordId ?? this.playingWordId),
      myWordsCount: myWordsCount ?? this.myWordsCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        words,
        query,
        level,
        hasMore,
        playingWordId,
        myWordsCount,
        errorMessage,
      ];
}
