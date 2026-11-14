import 'package:injectable/injectable.dart';

import '../../domain/entities/conversation_category.dart';
import '../../domain/entities/conversation_lesson.dart';
import '../../domain/entities/conversation_line.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/conversation_local_datasource.dart';

@LazySingleton(as: ConversationRepository)
class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationLocalDataSource _local;

  ConversationRepositoryImpl(this._local);

  @override
  Future<List<ConversationCategory>> getCategories() => _local.getCategories();

  @override
  Future<List<ConversationLesson>> getLessons(int categoryId) =>
      _local.getLessons(categoryId);

  @override
  Future<List<ConversationLine>> getLines(int lessonId) =>
      _local.getLines(lessonId);
}
