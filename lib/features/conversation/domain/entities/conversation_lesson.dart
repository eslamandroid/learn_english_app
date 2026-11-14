import 'package:equatable/equatable.dart';

class ConversationLesson extends Equatable {
  final int id;
  final int categoryId;
  final String title;
  final String titleAr;

  /// `conversation_lesson.duration` in seconds. Shown as a chip in the lesson
  /// row (e.g. "0:21"). Not used for playback (each line has its own clip).
  final int durationSeconds;

  /// Count of `conversation_sentence` rows for this lesson. Populated by the
  /// datasource via a COUNT subquery, not a direct column.
  final int lineCount;

  const ConversationLesson({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.titleAr,
    required this.durationSeconds,
    required this.lineCount,
  });

  ConversationLesson copyWith({int? lineCount}) => ConversationLesson(
        id: id,
        categoryId: categoryId,
        title: title,
        titleAr: titleAr,
        durationSeconds: durationSeconds,
        lineCount: lineCount ?? this.lineCount,
      );

  @override
  List<Object?> get props =>
      [id, categoryId, title, titleAr, durationSeconds, lineCount];
}
