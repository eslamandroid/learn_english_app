import 'package:equatable/equatable.dart';

import '../../../../shared/enums/cefr_level.dart';

class OnboardingState extends Equatable {
  final int currentPage;
  final CefrLevel? selectedLevel;
  final bool isCompleted;

  const OnboardingState({
    this.currentPage = 0,
    this.selectedLevel,
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    int? currentPage,
    CefrLevel? selectedLevel,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [currentPage, selectedLevel, isCompleted];
}
