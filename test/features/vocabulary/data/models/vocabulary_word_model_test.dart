import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/localization/content_localizer_impl.dart';
import 'package:learn_english_app/features/vocabulary/data/models/vocabulary_word_model.dart';

void main() {
  tearDown(() => ContentLocalizerImpl.instance.debugReset());

  test('fromMap returns same wordAr as before for ar locale (regression)', () {
    final map = <String, Object?>{
      'id': 1,
      'subTopicId': 5,
      'name': 'apple',
      'ita': 'تفاحة',
      'desc': 'A fruit',
      'imageResourceId': '',
      'sound': '',
      'trans': '/ˈæp.əl/',
      'usage': 'I eat an apple.',
    };
    final model = VocabularyWordModel.fromMap(map);
    expect(model.wordAr, 'تفاحة');
    expect(model.word, 'apple');
    expect(model.phonetic, '/ˈæp.əl/');
  });

  test('fromMap falls back to english word when ita is null', () {
    final map = <String, Object?>{
      'id': 2,
      'subTopicId': 5,
      'name': 'banana',
      'ita': null,
      'desc': '',
      'imageResourceId': '',
      'sound': '',
      'trans': '',
      'usage': '',
    };
    final model = VocabularyWordModel.fromMap(map);
    expect(model.wordAr, 'banana');
  });

  test('fromMap falls back to english when ita is empty string', () {
    final map = <String, Object?>{
      'id': 3,
      'subTopicId': 5,
      'name': 'cherry',
      'ita': '',
      'desc': '',
      'imageResourceId': '',
      'sound': '',
      'trans': '',
      'usage': '',
    };
    final model = VocabularyWordModel.fromMap(map);
    expect(model.wordAr, 'cherry');
  });
}
