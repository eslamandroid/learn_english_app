import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/database/user_db_schema.dart';
import 'package:learn_english_app/features/progress/data/datasources/progress_local_datasource.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late ProgressLocalDataSourceImpl sut;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.transaction((txn) async {
            for (final sql in UserDbSchema.v1Statements) {
              await txn.execute(sql);
            }
          });
        },
      ),
    );
    sut = ProgressLocalDataSourceImpl(db);
  });

  tearDown(() async => db.close());

  test('conversation progress is isolated from grammar/phonetics/sentences',
      () async {
    await sut.markGrammarSubtopicCompleted(1);
    await sut.markPhoneticTopicCompleted(2);
    await sut.markSentencesSubtopicCompleted(3);
    await sut.markConversationLessonCompleted(4);

    expect(await sut.getCompletedConversationLessons(), {4});
    expect(await sut.getCompletedGrammarSubtopics(), {1});
    expect(await sut.getCompletedPhoneticTopics(), {2});
    expect(await sut.getCompletedSentencesSubtopics(), {3});
  });

  test('setInProgress for conversation ignores a completed lesson', () async {
    await sut.markConversationLessonCompleted(10);
    await sut.setInProgressConversationLesson(10);
    expect(await sut.getInProgressConversationLesson(), isNull);
    expect(await sut.getCompletedConversationLessons(), contains(10));
  });

  test('setInProgress only one lesson in-progress at a time', () async {
    await sut.setInProgressConversationLesson(1);
    await sut.setInProgressConversationLesson(2);
    expect(await sut.getInProgressConversationLesson(), 2);
  });
}
