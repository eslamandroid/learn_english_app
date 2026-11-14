import '../entities/conversation_category.dart';
import '../entities/conversation_lesson.dart';
import '../entities/conversation_line.dart';

abstract class ConversationRepository {
  Future<List<ConversationCategory>> getCategories();

  /// Lessons for one category, with each lesson's lineCount populated via
  /// a COUNT subquery against `conversation_sentence`.
  Future<List<ConversationLesson>> getLessons(int categoryId);

  /// Lines of one lesson, in-script order (`conversation_sentence.id ASC`).
  Future<List<ConversationLine>> getLines(int lessonId);
}
