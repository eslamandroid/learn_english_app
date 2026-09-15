import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learn_english_app/base/constants/environment/environment_config.dart';
import 'package:learn_english_app/base/constants/preference/shared_preference_constants.dart';

abstract interface class LanguageLocalDatasource {
  Future<String> getCurrentLanguageCode();
  Future<bool> saveLanguageCode(String languageCode);
  Stream<String> observeLanguageChanges();
}

@LazySingleton(as: LanguageLocalDatasource)
class LanguageLocalDatasourceImpl implements LanguageLocalDatasource {
  final SharedPreferences _preferences;
  final BehaviorSubject<String> _languageController;

  LanguageLocalDatasourceImpl(this._preferences)
      : _languageController = BehaviorSubject<String>.seeded(
          _preferences.getString(SharedPreferenceKeys.languageCode) ??
              EnvironmentConfig.defaultLocale,
        );

  @override
  Future<String> getCurrentLanguageCode() async {
    final code = _preferences.getString(SharedPreferenceKeys.languageCode);
    return code ?? EnvironmentConfig.defaultLocale;
  }

  @override
  Future<bool> saveLanguageCode(String languageCode) async {
    final result = await _preferences.setString(
      SharedPreferenceKeys.languageCode,
      languageCode,
    );
    if (result) {
      _languageController.add(languageCode);
    }
    return result;
  }

  @override
  Stream<String> observeLanguageChanges() {
    return _languageController.stream;
  }

  void dispose() {
    _languageController.close();
  }
}

