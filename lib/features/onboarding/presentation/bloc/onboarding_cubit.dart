import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/enums/cefr_level.dart';
import 'onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  final SharedPreferences _prefs;
  static const int totalPages = 3;

  OnboardingCubit(this._prefs) : super(const OnboardingState());

  void nextPage() {
    if (state.currentPage < totalPages - 1) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      emit(state.copyWith(currentPage: state.currentPage - 1));
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      emit(state.copyWith(currentPage: page));
    }
  }

  void selectLevel(CefrLevel level) {
    emit(state.copyWith(selectedLevel: level));
  }

  Future<void> completeOnboarding() async {
    final level = state.selectedLevel ?? CefrLevel.a1;
    await _prefs.setString(AppConstants.prefSelectedLevel, level.key);
    await _prefs.setBool(AppConstants.prefOnboardingComplete, true);
    emit(state.copyWith(selectedLevel: level, isCompleted: true));
  }
}
