import 'package:equatable/equatable.dart';

import '../../../../progress/domain/entities/phonetics_progress.dart';
import '../../../domain/entities/phonetic_example.dart';

abstract class PhoneticDetailEvent extends Equatable {
  const PhoneticDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadPhoneticDetail extends PhoneticDetailEvent {
  final int topicId;
  final String accent;
  const LoadPhoneticDetail({required this.topicId, required this.accent});

  @override
  List<Object?> get props => [topicId, accent];
}

class ChangeAccent extends PhoneticDetailEvent {
  final String accent;
  const ChangeAccent({required this.accent});

  @override
  List<Object?> get props => [accent];
}

class PlayExampleAudio extends PhoneticDetailEvent {
  final PhoneticExample example;
  const PlayExampleAudio({required this.example});

  @override
  List<Object?> get props => [example];
}

class StopExampleAudio extends PhoneticDetailEvent {
  const StopExampleAudio();
}

/// Plays the topic's phoneme clip from `assets/sounds/{assetName}.m4a`.
class PlayTopicSound extends PhoneticDetailEvent {
  final String assetName;
  const PlayTopicSound({required this.assetName});

  @override
  List<Object?> get props => [assetName];
}

class StopTopicSound extends PhoneticDetailEvent {
  const StopTopicSound();
}

/// User tapped the "Mark as completed" CTA at the bottom of the detail
/// screen. Flips this topic to completed in the progress store.
class FinishPhoneticTopic extends PhoneticDetailEvent {
  const FinishPhoneticTopic();
}

/// Internal event — fired by the bloc when the progress stream emits a new
/// snapshot.
class PhoneticDetailProgressChanged extends PhoneticDetailEvent {
  final PhoneticsProgress progress;
  const PhoneticDetailProgressChanged({required this.progress});

  @override
  List<Object?> get props => [progress];
}
