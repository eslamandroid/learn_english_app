import 'package:equatable/equatable.dart';

import '../../../domain/entities/sentence_item.dart';

sealed class SentenceContentState extends Equatable {
  const SentenceContentState();
  @override
  List<Object?> get props => [];
}

class SentenceContentInitial extends SentenceContentState {
  const SentenceContentInitial();
}

class SentenceContentLoading extends SentenceContentState {
  const SentenceContentLoading();
}

class SentenceContentLoaded extends SentenceContentState {
  final List<SentenceItem> sentences;
  final int? playingId;
  final bool isCompleted;

  const SentenceContentLoaded({
    required this.sentences,
    this.playingId,
    this.isCompleted = false,
  });

  SentenceContentLoaded copyWith({
    int? playingId,
    bool? isCompleted,
    bool clearPlaying = false,
  }) {
    return SentenceContentLoaded(
      sentences: sentences,
      playingId: clearPlaying ? null : (playingId ?? this.playingId),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [sentences, playingId, isCompleted];
}

class SentenceContentError extends SentenceContentState {
  final String message;
  const SentenceContentError({required this.message});
  @override
  List<Object?> get props => [message];
}
