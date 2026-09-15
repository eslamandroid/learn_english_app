import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:learn_english_app/base/base.dart';
import 'package:learn_english_app/features/language/domain/domain.dart';

part 'language_state.freezed.dart';

@freezed
abstract class LanguageState with _$LanguageState {
  const factory LanguageState({
    bool? loading,
    bool? progress,
    LanguageModel? currentLanguage,
    List<LanguageModel>? supportedLanguages,
    bool? success,
    String? screenId,
    AppException? appException,
  }) = _LanguageState;
}

