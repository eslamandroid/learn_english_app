import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/localization/content_localizer_impl.dart';
import 'package:learn_english_app/features/grammar/data/models/grammar_topic_model.dart';

void main() {
  tearDown(() => ContentLocalizerImpl.instance.debugReset());

  test('fromMap returns same titleAr as before for ar locale (regression)', () {
    final map = <String, Object?>{
      'id': 1,
      'title': 'Verb Tenses',
      'titleAr': 'أزمنة الفعل',
      'description': 'A description',
      'descriptionAr': 'وصف بالعربية',
    };
    final model = GrammarTopicModel.fromMap(map);
    expect(model.titleAr, 'أزمنة الفعل');
    expect(model.descriptionAr, 'وصف بالعربية');
    expect(model.title, 'Verb Tenses');
  });

  test('fromMap falls back to english when titleAr is null', () {
    final map = <String, Object?>{
      'id': 2,
      'title': 'Verb Tenses',
      'titleAr': null,
      'description': null,
      'descriptionAr': null,
    };
    final model = GrammarTopicModel.fromMap(map);
    expect(model.titleAr, 'Verb Tenses');
    expect(model.descriptionAr, isNull);
  });

  test('fromMap titleAr empty string falls back to english', () {
    final map = <String, Object?>{
      'id': 3,
      'title': 'Adjectives',
      'titleAr': '',
    };
    final model = GrammarTopicModel.fromMap(map);
    expect(model.titleAr, 'Adjectives');
  });
}
