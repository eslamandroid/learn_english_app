import 'package:injectable/injectable.dart';
import 'package:learn_english_app/base/constants/environment/environment_config.dart';
import 'package:learn_english_app/features/language/data/datasource/local/language_local_datasource.dart';
import 'package:learn_english_app/features/language/domain/domain.dart';

@LazySingleton(as: LanguageRepository)
class LanguageRepositoryImpl implements LanguageRepository {
  final LanguageLocalDatasource _localDatasource;

  LanguageRepositoryImpl(this._localDatasource);

  @override
  Future<LanguageModel> getCurrentLanguage() async {
    final languageCode = await _localDatasource.getCurrentLanguageCode();
    final language = LanguageModel.getByCode(languageCode);
    
    // If language not found, return default language
    if (language == null) {
      final defaultLang = LanguageModel.getByCode(EnvironmentConfig.defaultLocale);
      return defaultLang ?? LanguageModel.supportedLanguages.first;
    }
    
    return language;
  }

  @override
  Future<bool> changeLanguage(String languageCode) async {
    // Validate if language is supported
    final language = LanguageModel.getByCode(languageCode);
    if (language == null) {
      throw Exception('Language code $languageCode is not supported');
    }

    return await _localDatasource.saveLanguageCode(languageCode);
  }

  @override
  List<LanguageModel> getSupportedLanguages() {
    return LanguageModel.supportedLanguages;
  }

  @override
  Stream<LanguageModel> observeLanguageChanges() {
    return _localDatasource.observeLanguageChanges().map((languageCode) {
      final language = LanguageModel.getByCode(languageCode);
      return language ?? LanguageModel.supportedLanguages.first;
    });
  }
}

