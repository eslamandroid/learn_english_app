import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/localization/content_localizer_impl.dart';
import 'package:learn_english_app/features/phonetics/data/models/phonetic_topic_model.dart';

void main() {
  tearDown(() => ContentLocalizerImpl.instance.debugReset());

  test('fromMap returns same titleAr as before for ar locale (regression)', () {
    final map = <String, Object?>{
      'id': 10,
      'subId': 1,
      'title': 'Short Vowels',
      'title_ar': 'الحروف المتحركة القصيرة',
      'phoneTitle': '/æ/',
      'word': null,
      'icon': null,
      'sound': null,
    };
    final model = PhoneticTopicModel.fromMap(map);
    expect(model.titleAr, 'الحروف المتحركة القصيرة');
    expect(model.title, 'Short Vowels');
  });

  test('fromMap falls back to english when title_ar is null', () {
    final map = <String, Object?>{
      'id': 11,
      'subId': 1,
      'title': 'Long Vowels',
      'title_ar': null,
      'phoneTitle': null,
      'word': null,
      'icon': null,
      'sound': null,
    };
    final model = PhoneticTopicModel.fromMap(map);
    expect(model.titleAr, 'Long Vowels');
  });
}
