import '../model/language_model.dart';

abstract class LanguageRepository {
  /// Get the current selected language
  Future<LanguageModel> getCurrentLanguage();

  /// Change the app language
  Future<bool> changeLanguage(String languageCode);

  /// Get all supported languages
  List<LanguageModel> getSupportedLanguages();

  /// Observe language changes
  Stream<LanguageModel> observeLanguageChanges();
}

