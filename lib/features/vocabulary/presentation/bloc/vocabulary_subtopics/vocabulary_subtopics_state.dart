import 'package:equatable/equatable.dart';

import '../../../domain/entities/vocabulary_subtopic.dart';

sealed class VocabularySubtopicsState extends Equatable {
  const VocabularySubtopicsState();

  @override
  List<Object?> get props => [];
}

class VocabularySubtopicsInitial extends VocabularySubtopicsState {
  const VocabularySubtopicsInitial();
}

class VocabularySubtopicsLoading extends VocabularySubtopicsState {
  const VocabularySubtopicsLoading();
}

class VocabularySubtopicsLoaded extends VocabularySubtopicsState {
  final List<VocabularySubtopic> subtopics;
  const VocabularySubtopicsLoaded({required this.subtopics});

  @override
  List<Object?> get props => [subtopics];
}

class VocabularySubtopicsError extends VocabularySubtopicsState {
  final String message;
  const VocabularySubtopicsError({required this.message});

  @override
  List<Object?> get props => [message];
}
