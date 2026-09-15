import 'package:equatable/equatable.dart';

import '../../../../progress/domain/entities/phonetics_progress.dart';
import '../../../domain/entities/phonetic_topic.dart';

abstract class PhoneticTopicsState extends Equatable {
  const PhoneticTopicsState();

  @override
  List<Object?> get props => [];
}

class PhoneticTopicsInitial extends PhoneticTopicsState {
  const PhoneticTopicsInitial();
}

class PhoneticTopicsLoading extends PhoneticTopicsState {
  const PhoneticTopicsLoading();
}

class PhoneticTopicsLoaded extends PhoneticTopicsState {
  final List<PhoneticTopic> topics;
  final PhoneticsProgress progress;

  const PhoneticTopicsLoaded({
    required this.topics,
    this.progress = PhoneticsProgress.empty,
  });

  PhoneticTopicsLoaded copyWith({
    List<PhoneticTopic>? topics,
    PhoneticsProgress? progress,
  }) {
    return PhoneticTopicsLoaded(
      topics: topics ?? this.topics,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [topics, progress];
}

class PhoneticTopicsError extends PhoneticTopicsState {
  final String message;
  const PhoneticTopicsError({required this.message});

  @override
  List<Object?> get props => [message];
}
