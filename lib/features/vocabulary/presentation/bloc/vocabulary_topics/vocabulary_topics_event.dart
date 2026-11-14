import 'package:equatable/equatable.dart';

abstract class VocabularyTopicsEvent extends Equatable {
  const VocabularyTopicsEvent();

  @override
  List<Object?> get props => [];
}

class LoadVocabularyTopics extends VocabularyTopicsEvent {
  /// Pass `null` to load all topics; otherwise only topics belonging to that
  /// CEFR level (1..6) are returned.
  final int? levelId;
  const LoadVocabularyTopics({this.levelId});

  @override
  List<Object?> get props => [levelId];
}
