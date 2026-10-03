import 'package:equatable/equatable.dart';

import '../../../../shared/enums/cefr_level.dart';

/// One `word_list` row joined with the user's `my_word_list` save state.
/// `isSaved` is derived at query time, not a column on `word_list`.
class DictionaryWord extends Equatable {
  final int id;
  final String word;
  final String arabic;
  final String pronunciation;
  final String example;
  final CefrLevel level;
  final bool isSaved;

  const DictionaryWord({
    required this.id,
    required this.word,
    required this.arabic,
    required this.pronunciation,
    required this.example,
    required this.level,
    required this.isSaved,
  });

  DictionaryWord copyWith({bool? isSaved}) => DictionaryWord(
        id: id,
        word: word,
        arabic: arabic,
        pronunciation: pronunciation,
        example: example,
        level: level,
        isSaved: isSaved ?? this.isSaved,
      );

  @override
  List<Object?> get props =>
      [id, word, arabic, pronunciation, example, level, isSaved];
}
