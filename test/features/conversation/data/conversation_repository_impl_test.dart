import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/features/conversation/data/datasources/conversation_local_datasource.dart';
import 'package:learn_english_app/features/conversation/data/models/conversation_category_model.dart';
import 'package:learn_english_app/features/conversation/data/models/conversation_lesson_model.dart';
import 'package:learn_english_app/features/conversation/data/models/conversation_line_model.dart';
import 'package:learn_english_app/features/conversation/data/repositories/conversation_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocal extends Mock implements ConversationLocalDataSource {}

void main() {
  late _MockLocal local;
  late ConversationRepositoryImpl sut;

  setUp(() {
    local = _MockLocal();
    sut = ConversationRepositoryImpl(local);
  });

  test('getCategories delegates to datasource', () async {
    final cats = [
      ConversationCategoryModel.fromMap({
        'id': 1,
        'title': 'General',
        'titleAr': 'عام',
        'itemCount': 13,
        'level': 1,
      }),
    ];
    when(() => local.getCategories()).thenAnswer((_) async => cats);
    final result = await sut.getCategories();
    expect(result.length, 1);
    expect(result.first.id, 1);
  });

  test('getLessons passes categoryId through', () async {
    final lessons = [
      ConversationLessonModel.fromMap({
        'id': 1,
        'level_id': 5,
        'title': 'Hello',
        'titleAr': 'مرحبا',
        'duration': 20,
        'line_count': 3,
      }),
    ];
    when(() => local.getLessons(5)).thenAnswer((_) async => lessons);
    final result = await sut.getLessons(5);
    expect(result.length, 1);
    expect(result.first.lineCount, 3);
    verify(() => local.getLessons(5)).called(1);
  });

  test('getLines passes lessonId through', () async {
    final lines = [
      ConversationLineModel.fromMap({
        'id': 7,
        'lesson': 2,
        'character': 'Lisa',
        'start': 0,
        'end': 0,
        'sentence': 'Hi.',
        'phonetic': '{Hi | haɪ}.',
        'sentenceAr': 'مرحبا.',
      }),
    ];
    when(() => local.getLines(2)).thenAnswer((_) async => lines);
    final result = await sut.getLines(2);
    expect(result.first.phonetic, 'haɪ.');
    verify(() => local.getLines(2)).called(1);
  });
}
