import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../shared/enums/cefr_level.dart';
import '../../domain/entities/dictionary_word.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../datasources/dictionary_local_datasource.dart';
import '../datasources/my_words_local_datasource.dart';
import '../models/dictionary_word_model.dart';

@LazySingleton(as: DictionaryRepository)
class DictionaryRepositoryImpl implements DictionaryRepository {
  final DictionaryLocalDataSource _content;
  final MyWordsLocalDataSource _user;

  final StreamController<void> _changes =
      StreamController<void>.broadcast();

  DictionaryRepositoryImpl(this._content, this._user);

  @override
  Stream<void> get savedChanges => _changes.stream;

  @override
  Future<List<DictionaryWord>> search({
    String? query,
    CefrLevel? level,
    int limit = 50,
    int offset = 0,
  }) async {
    // Fetch saved set once per page — annotates every row with isSaved in O(n).
    final saved = await _user.getSavedWordsLower();
    final rows = await _content.search(
      query: query,
      level: level,
      limit: limit,
      offset: offset,
    );
    return [
      for (final r in rows)
        DictionaryWordModel.fromMap(
          r,
          isSaved: saved.contains((r['word'] as String).toLowerCase()),
        ),
    ];
  }

  @override
  Future<List<DictionaryWord>> getMyWords() async {
    final rows = await _user.getAll();
    final out = <DictionaryWord>[];
    for (final row in rows) {
      final srcId = row['source_id'] as int?;
      Map<String, Object?>? wl;
      if (srcId != null) wl = await _content.getById(srcId);
      out.add(DictionaryWordModel.fromMyWordsJoin(
        myWordRow: row,
        wordListRow: wl,
      ));
    }
    return out;
  }

  @override
  Future<void> saveWord(DictionaryWord word) async {
    await _user.save(
      word: word.word,
      translation: word.arabic,
      sourceId: word.id,
    );
    _changes.add(null);
  }

  @override
  Future<void> removeWord(String word) async {
    await _user.remove(word);
    _changes.add(null);
  }

  @override
  @disposeMethod
  Future<void> dispose() => _changes.close();
}
