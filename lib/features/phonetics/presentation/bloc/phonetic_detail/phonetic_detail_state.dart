import 'package:equatable/equatable.dart';

import '../../../domain/entities/phonetic_example.dart';
import '../../../domain/entities/phonetic_section.dart';
import '../../../domain/entities/phonetic_topic.dart';

abstract class PhoneticDetailState extends Equatable {
  const PhoneticDetailState();

  @override
  List<Object?> get props => [];
}

class PhoneticDetailInitial extends PhoneticDetailState {
  const PhoneticDetailInitial();
}

class PhoneticDetailLoading extends PhoneticDetailState {
  const PhoneticDetailLoading();
}

class PhoneticDetailLoaded extends PhoneticDetailState {
  final PhoneticTopic? topic;
  final List<PhoneticSection> sections;
  final String currentAccent;
  final PhoneticExample? playingExample;
  final bool playingSound;

  /// Mirrors the `PhoneticsProgress` snapshot — switches the bottom CTA
  /// between "Mark as completed" and "Completed".
  final bool isCompleted;

  const PhoneticDetailLoaded({
    required this.topic,
    required this.sections,
    required this.currentAccent,
    this.playingExample,
    this.playingSound = false,
    this.isCompleted = false,
  });

  PhoneticDetailLoaded copyWith({
    PhoneticTopic? topic,
    List<PhoneticSection>? sections,
    String? currentAccent,
    PhoneticExample? playingExample,
    bool clearPlayingExample = false,
    bool? playingSound,
    bool? isCompleted,
  }) {
    return PhoneticDetailLoaded(
      topic: topic ?? this.topic,
      sections: sections ?? this.sections,
      currentAccent: currentAccent ?? this.currentAccent,
      playingExample: clearPlayingExample
          ? null
          : (playingExample ?? this.playingExample),
      playingSound: playingSound ?? this.playingSound,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        topic,
        sections,
        currentAccent,
        playingExample,
        playingSound,
        isCompleted,
      ];
}

class PhoneticDetailError extends PhoneticDetailState {
  final String message;
  const PhoneticDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
