import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:learn_english_app/features/language/domain/domain.dart';

import 'language_event.dart';
import 'language_state.dart';

@Injectable()
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final GetCurrentLanguageUsecase _getCurrentLanguageUsecase;
  final ChangeLanguageUsecase _changeLanguageUsecase;
  final GetSupportedLanguagesUsecase _getSupportedLanguagesUsecase;
  final ObserveLanguageUsecase _observeLanguageUsecase;

  LanguageBloc(
    this._getCurrentLanguageUsecase,
    this._changeLanguageUsecase,
    this._getSupportedLanguagesUsecase,
    this._observeLanguageUsecase,
  ) : super(const LanguageState(loading: true)) {
    on<LoadCurrentLanguageEvent>(_onLoadCurrentLanguage);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<ObserveLanguageChangesEvent>(_onObserveLanguageChanges);
  }

  Future<void> _onLoadCurrentLanguage(
    LoadCurrentLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    emit(state.copyWith(
      loading: true,
      success: null,
      appException: null,
    ));

    // Get supported languages
    final supportedLanguagesResult = _getSupportedLanguagesUsecase.execute();
    final supportedLanguages = supportedLanguagesResult.getOrElse((_) => []);

    // Get current language
    (await _getCurrentLanguageUsecase.execute()).fold(
      (error) => emit(state.copyWith(
        loading: false,
        appException: error,
        supportedLanguages: supportedLanguages,
      )),
      (language) => emit(state.copyWith(
        loading: false,
        currentLanguage: language,
        supportedLanguages: supportedLanguages,
        appException: null,
      )),
    );
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    emit(state.copyWith(
      progress: true,
      success: null,
      screenId: event.screenId,
      appException: null,
    ));

    (await _changeLanguageUsecase.execute(event.languageCode)).fold(
      (error) => emit(state.copyWith(
        progress: false,
        success: false,
        appException: error,
      )),
      (success) async {
        // Get the updated language
        final languageResult = await _getCurrentLanguageUsecase.execute();
        languageResult.fold(
          (error) => emit(state.copyWith(
            progress: false,
            success: false,
            appException: error,
          )),
          (language) => emit(state.copyWith(
            progress: false,
            success: true,
            currentLanguage: language,
            appException: null,
          )),
        );
      },
    );
  }

  Future<void> _onObserveLanguageChanges(
    ObserveLanguageChangesEvent event,
    Emitter<LanguageState> emit,
  ) async {
    await emit.forEach(
      _observeLanguageUsecase.execute(),
      onData: (language) => state.copyWith(
        currentLanguage: language,
        progress: false,
        loading: false,
        appException: null,
      ),
    );
  }
}

