import 'package:equatable/equatable.dart';

import '../../../../progress/domain/entities/phonetics_progress.dart';

abstract class PhoneticCategoriesEvent extends Equatable {
  const PhoneticCategoriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPhoneticCategories extends PhoneticCategoriesEvent {
  const LoadPhoneticCategories();
}

/// Internal event — fired by the bloc when the progress stream emits a new
/// snapshot. Keeps the reducer pure.
class PhoneticsProgressChanged extends PhoneticCategoriesEvent {
  final PhoneticsProgress progress;
  const PhoneticsProgressChanged({required this.progress});

  @override
  List<Object?> get props => [progress];
}
