import 'package:equatable/equatable.dart';

import '../../../../../core/utils/voice_preferences.dart';
import '../../../../../shared/enums/playback_speed.dart';
import '../../../domain/entities/vocabulary_word.dart';

sealed class VocabularyWordsState extends Equatable {
  const VocabularyWordsState();

  @override
  List<Object?> get props => [];
}

class VocabularyWordsInitial extends VocabularyWordsState {
  const VocabularyWordsInitial();
}

class VocabularyWordsLoading extends VocabularyWordsState {
  const VocabularyWordsLoading();
}

class VocabularyWordsLoaded extends VocabularyWordsState {
  final List<VocabularyWord> words;
  final int currentIndex;

  /// Id of the word whose audio is currently playing, or null when idle.
  final int? playingWordId;

  /// Id of the word whose example sentence is being spoken.
  final int? playingExampleWordId;

  final VoiceAccent accent;
  final PlaybackSpeed speed;

  const VocabularyWordsLoaded({
    required this.words,
    this.currentIndex = 0,
    this.playingWordId,
    this.playingExampleWordId,
    this.accent = VoiceAccent.us,
    this.speed = PlaybackSpeed.normal,
  });

  VocabularyWord? get currentWord =>
      (currentIndex >= 0 && currentIndex < words.length)
          ? words[currentIndex]
          : null;

  VocabularyWordsLoaded copyWith({
    List<VocabularyWord>? words,
    int? currentIndex,
    int? playingWordId,
    int? playingExampleWordId,
    bool clearPlaying = false,
    VoiceAccent? accent,
    PlaybackSpeed? speed,
  }) {
    return VocabularyWordsLoaded(
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      playingWordId:
          clearPlaying ? null : (playingWordId ?? this.playingWordId),
      playingExampleWordId:
          clearPlaying
              ? null
              : (playingExampleWordId ?? this.playingExampleWordId),
      accent: accent ?? this.accent,
      speed: speed ?? this.speed,
    );
  }

  @override
  List<Object?> get props => [
    words,
    currentIndex,
    playingWordId,
    playingExampleWordId,
    accent,
    speed,
  ];
}

class VocabularyWordsError extends VocabularyWordsState {
  final String message;
  const VocabularyWordsError({required this.message});

  @override
  List<Object?> get props => [message];
}
