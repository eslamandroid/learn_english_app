import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/features/conversation/data/models/conversation_line_model.dart';

void main() {
  group('ConversationLineModel.fromMap', () {
    test('extracts IPA from phonetic column via PhoneticParser', () {
      final line = ConversationLineModel.fromMap({
        'id': 3,
        'lesson': 1,
        'character': 'James',
        'start': 0,
        'end': 0,
        'sentence': 'How are you?',
        'phonetic': '{How | haʊ} {are | ɑː} {you | juː}?',
        'sentenceAr': 'كيف حالك؟',
      });
      expect(line.phonetic, 'haʊ ɑː juː?');
      expect(line.english, 'How are you?');
      expect(line.id, 3);
      expect(line.lessonId, 1);
      expect(line.character, 'James');
      expect(line.arabic.isNotEmpty, isTrue);
    });

    test('tolerates missing phonetic / empty strings', () {
      final line = ConversationLineModel.fromMap({
        'id': 1,
        'lesson': 1,
        'character': 'Mary',
        'start': 0,
        'end': 0,
        'sentence': 'Hello.',
        'phonetic': '',
        'sentenceAr': 'مرحبا.',
      });
      expect(line.phonetic, '');
      expect(line.english, 'Hello.');
    });
  });
}
