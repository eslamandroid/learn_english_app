import 'package:equatable/equatable.dart';

import '../../../../progress/domain/entities/phonetics_progress.dart';

abstract class PhoneticTopicsEvent extends Equatable {
  const PhoneticTopicsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPhoneticTopics extends PhoneticTopicsEvent {
  final int categoryId;
  const LoadPhoneticTopics({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class PhoneticsTopicsProgressChanged extends PhoneticTopicsEvent {
  final PhoneticsProgress progress;
  const PhoneticsTopicsProgressChanged({required this.progress});

  @override
  List<Object?> get props => [progress];
}
