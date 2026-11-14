import 'package:equatable/equatable.dart';

abstract class ConversationLessonsEvent extends Equatable {
  const ConversationLessonsEvent();
  @override
  List<Object?> get props => [];
}

class LoadConversationLessons extends ConversationLessonsEvent {
  final int categoryId;
  const LoadConversationLessons({required this.categoryId});
  @override
  List<Object?> get props => [categoryId];
}

class ConversationLessonsProgressRefreshed extends ConversationLessonsEvent {
  const ConversationLessonsProgressRefreshed();
}
