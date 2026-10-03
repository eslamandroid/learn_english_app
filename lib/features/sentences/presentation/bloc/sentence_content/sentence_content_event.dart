import 'package:equatable/equatable.dart';

abstract class SentenceContentEvent extends Equatable {
  const SentenceContentEvent();
  @override
  List<Object?> get props => [];
}

class LoadSentenceContent extends SentenceContentEvent {
  final int subtopicId;
  const LoadSentenceContent({required this.subtopicId});
  @override
  List<Object?> get props => [subtopicId];
}

class PlaySentenceAudio extends SentenceContentEvent {
  final int sentenceId;
  const PlaySentenceAudio({required this.sentenceId});
  @override
  List<Object?> get props => [sentenceId];
}

class StopSentenceAudio extends SentenceContentEvent {
  const StopSentenceAudio();
}

class MarkSentenceContentComplete extends SentenceContentEvent {
  final int subtopicId;
  const MarkSentenceContentComplete({required this.subtopicId});
  @override
  List<Object?> get props => [subtopicId];
}

/// User has reached (viewed) at least the 1-based [index] sentence in the
/// lesson. Writes to `sentence_lesson_progress.seen` (monotonic).
class TrackSentenceSeen extends SentenceContentEvent {
  final int subtopicId;
  final int oneBasedIndex;
  const TrackSentenceSeen({
    required this.subtopicId,
    required this.oneBasedIndex,
  });
  @override
  List<Object?> get props => [subtopicId, oneBasedIndex];
}
