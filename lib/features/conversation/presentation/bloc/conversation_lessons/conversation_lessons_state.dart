import 'package:equatable/equatable.dart';

import '../../../../../features/progress/domain/entities/conversation_progress.dart';
import '../../../domain/entities/conversation_lesson.dart';

sealed class ConversationLessonsState extends Equatable {
  const ConversationLessonsState();
  @override
  List<Object?> get props => [];
}

class ConversationLessonsInitial extends ConversationLessonsState {
  const ConversationLessonsInitial();
}

class ConversationLessonsLoading extends ConversationLessonsState {
  const ConversationLessonsLoading();
}

class ConversationLessonsLoaded extends ConversationLessonsState {
  final List<ConversationLesson> lessons;
  final ConversationProgress progress;

  const ConversationLessonsLoaded({
    required this.lessons,
    required this.progress,
  });

  ConversationLessonsLoaded copyWith({
    List<ConversationLesson>? lessons,
    ConversationProgress? progress,
  }) {
    return ConversationLessonsLoaded(
      lessons: lessons ?? this.lessons,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [lessons, progress];
}

class ConversationLessonsError extends ConversationLessonsState {
  final String message;
  const ConversationLessonsError({required this.message});
  @override
  List<Object?> get props => [message];
}
