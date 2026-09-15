import 'package:equatable/equatable.dart';

class LevelParams extends Equatable {
  final int levelId;
  const LevelParams({required this.levelId});

  @override
  List<Object?> get props => [levelId];
}

class TopicParams extends Equatable {
  final int topicId;
  const TopicParams({required this.topicId});

  @override
  List<Object?> get props => [topicId];
}

class SubtopicParams extends Equatable {
  final int subtopicId;
  const SubtopicParams({required this.subtopicId});

  @override
  List<Object?> get props => [subtopicId];
}

class LessonParams extends Equatable {
  final int lessonId;
  const LessonParams({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

class SearchParams extends Equatable {
  final String query;
  const SearchParams({required this.query});

  @override
  List<Object?> get props => [query];
}
