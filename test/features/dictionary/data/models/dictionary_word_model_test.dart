import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/features/dictionary/data/models/dictionary_word_model.dart';
import 'package:learn_english_app/shared/enums/cefr_level.dart';

void main() {
  Map<String, Object?> row(String level) => {
        'id': 1,
        'word': 'about',
        'word_ar': 'عن',
        'pronunciation': '/əˈbaʊt/',
        'example': 'The book is about wizards.',
        'level': level,
      };

  group('DictionaryWordModel.fromMap', () {
    test('maps each CEFR level string correctly', () {
      final cases = {
        'A1': CefrLevel.a1,
        'A2': CefrLevel.a2,
        'B1': CefrLevel.b1,
        'B2': CefrLevel.b2,
        'C1': CefrLevel.c1,
        'C2': CefrLevel.c2,
      };
      cases.forEach((input, expected) {
        final w = DictionaryWordModel.fromMap(row(input), isSaved: false);
        expect(w.level, expected, reason: 'input=$input');
      });
    });

    test('populates string fields and isSaved from arg', () {
      final w = DictionaryWordModel.fromMap(row('B1'), isSaved: true);
      expect(w.id, 1);
      expect(w.word, 'about');
      expect(w.pronunciation, '/əˈbaʊt/');
      expect(w.example, 'The book is about wizards.');
      expect(w.isSaved, isTrue);
      // Without a bound ContentLocalizer the fallback preserves the Arabic
      // column directly — that's enough to confirm the arabic field is wired.
      expect(w.arabic.isNotEmpty, isTrue);
    });

    test('tolerates null pronunciation / example', () {
      final w = DictionaryWordModel.fromMap({
        'id': 9,
        'word': 'test',
        'word_ar': 'اختبار',
        'pronunciation': null,
        'example': null,
        'level': 'A1',
      }, isSaved: false);
      expect(w.pronunciation, '');
      expect(w.example, '');
    });
  });

  group('DictionaryWordModel.fromMyWordsJoin', () {
    test('uses word_list row when present', () {
      final w = DictionaryWordModel.fromMyWordsJoin(
        myWordRow: {
          'word': 'about',
          'translation': 'عن',
          'source_id': 1,
        },
        wordListRow: row('A1'),
      );
      expect(w.pronunciation, '/əˈbaʊt/');
      expect(w.level, CefrLevel.a1);
      expect(w.isSaved, isTrue);
    });

    test('falls back to my_word_list fields on orphan save', () {
      final w = DictionaryWordModel.fromMyWordsJoin(
        myWordRow: {
          'word': 'ghost',
          'translation': 'شبح',
          'source_id': 999,
        },
        wordListRow: null,
      );
      expect(w.word, 'ghost');
      expect(w.arabic, 'شبح');
      expect(w.pronunciation, '');
      expect(w.level, CefrLevel.a1);
      expect(w.isSaved, isTrue);
    });
  });
}
