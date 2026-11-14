import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/localization/content_localizer_impl.dart';
import 'package:learn_english_app/features/sentences/data/models/sentence_item_model.dart';

void main() {
  tearDown(() => ContentLocalizerImpl.instance.debugReset());

  test('arabic equals sentencesAr for ar locale (regression)', () {
    final map = <String, Object?>{
      'id': 1,
      'subTopicId': 1,
      'sentencesGrammarEn': 'Hi there',
      'sentencesEn': 'Hi there',
      'sentencesAr': 'أهلاً',
      'example': 'Oh, it\'s you! Hi there!',
      'sentenceTitleEn': null,
      'answers': null,
    };
    final model = SentenceItemModel.fromMap(map);
    expect(model.arabic, 'أهلاً');
    expect(model.english, 'Hi there');
    expect(model.example, 'Oh, it\'s you! Hi there!');
    expect(model.suggestedReply, isNull);
  });

  test('falls back to english when sentencesAr is null', () {
    final map = <String, Object?>{
      'id': 2,
      'subTopicId': 1,
      'sentencesGrammarEn': 'Hello',
      'sentencesEn': 'Hello',
      'sentencesAr': null,
      'example': null,
      'sentenceTitleEn': null,
      'answers': null,
    };
    final model = SentenceItemModel.fromMap(map);
    expect(model.arabic, 'Hello');
    expect(model.suggestedReply, isNull);
  });

  test('suggestedReply populated when answers non-empty', () {
    final map = <String, Object?>{
      'id': 3,
      'subTopicId': 1,
      'sentencesGrammarEn': 'What\'s your name?',
      'sentencesEn': 'What\'s your name?',
      'sentencesAr': 'ما اسمك؟',
      'example': null,
      'sentenceTitleEn': null,
      'answers': 'My name is Sophia.',
    };
    final model = SentenceItemModel.fromMap(map);
    expect(model.suggestedReply, 'My name is Sophia.');
  });

  test('empty string answers treated as null', () {
    final map = <String, Object?>{
      'id': 4,
      'subTopicId': 1,
      'sentencesGrammarEn': 'Test',
      'sentencesEn': 'Test',
      'sentencesAr': null,
      'example': '',
      'sentenceTitleEn': null,
      'answers': '   ',
    };
    final model = SentenceItemModel.fromMap(map);
    expect(model.example, isNull);
    expect(model.suggestedReply, isNull);
  });
}
