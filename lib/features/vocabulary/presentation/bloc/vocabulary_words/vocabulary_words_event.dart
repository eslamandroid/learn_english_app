import 'package:equatable/equatable.dart';

import '../../../../../core/utils/voice_preferences.dart';
import '../../../../../shared/enums/playback_speed.dart';

abstract class VocabularyWordsEvent extends Equatable {
  const VocabularyWordsEvent();

  @override
  List<Object?> get props => [];
}

class LoadVocabularyWords extends VocabularyWordsEvent {
  final int subtopicId;
  const LoadVocabularyWords({required this.subtopicId});

  @override
  List<Object?> get props => [subtopicId];
}

/// User tapped the play button on the currently-displayed word.
class PlayVocabularyWord extends VocabularyWordsEvent {
  final int wordId;
  const PlayVocabularyWord({required this.wordId});

  @override
  List<Object?> get props => [wordId];
}

/// Speaks the example sentence for the currently displayed word.
class PlayVocabularyExample extends VocabularyWordsEvent {
  final int wordId;
  const PlayVocabularyExample({required this.wordId});

  @override
  List<Object?> get props => [wordId];
}

class StopVocabularyWord extends VocabularyWordsEvent {
  const StopVocabularyWord();
}

/// User swiped or tapped next/prev — moves the pager and stops any playback.
class ChangeVocabularyWordIndex extends VocabularyWordsEvent {
  final int index;
  const ChangeVocabularyWordIndex({required this.index});

  @override
  List<Object?> get props => [index];
}

/// User flipped the US/UK segmented control on the word detail card. Persists
/// through [AppVoicePreferences] so it stays consistent with Settings.
class SetVocabularyWordAccent extends VocabularyWordsEvent {
  final VoiceAccent accent;
  const SetVocabularyWordAccent({required this.accent});

  @override
  List<Object?> get props => [accent];
}

/// User flipped the Slow/Normal playback speed toggle. Kept in-memory only —
/// the default resets to normal each time the screen re-opens so users don't
/// leave "slow" mode on by accident.
class SetVocabularyWordSpeed extends VocabularyWordsEvent {
  final PlaybackSpeed speed;
  const SetVocabularyWordSpeed({required this.speed});

  @override
  List<Object?> get props => [speed];
}
