import 'package:equatable/equatable.dart';

import '../../../domain/entities/vocabulary_topic.dart';

sealed class VocabularyTopicsState extends Equatable {
  const VocabularyTopicsState();

  @override
  List<Object?> get props => [];
}

class VocabularyTopicsInitial extends VocabularyTopicsState {
  const VocabularyTopicsInitial();
}

class VocabularyTopicsLoading extends VocabularyTopicsState {
  const VocabularyTopicsLoading();
}

class VocabularyTopicsLoaded extends VocabularyTopicsState {
  final List<VocabularyTopic> topics;
  const VocabularyTopicsLoaded({required this.topics});

  @override
  List<Object?> get props => [topics];
}

class VocabularyTopicsError extends VocabularyTopicsState {
  final String message;
  const VocabularyTopicsError({required this.message});

  @override
  List<Object?> get props => [message];
}
