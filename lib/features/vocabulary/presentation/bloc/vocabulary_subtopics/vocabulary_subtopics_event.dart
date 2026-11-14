import 'package:equatable/equatable.dart';

abstract class VocabularySubtopicsEvent extends Equatable {
  const VocabularySubtopicsEvent();

  @override
  List<Object?> get props => [];
}

class LoadVocabularySubtopics extends VocabularySubtopicsEvent {
  final int topicId;
  const LoadVocabularySubtopics({required this.topicId});

  @override
  List<Object?> get props => [topicId];
}
