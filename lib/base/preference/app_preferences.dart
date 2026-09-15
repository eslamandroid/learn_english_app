import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:learn_english_app/base/constants/server/server_request_response_constants.dart';
import 'package:learn_english_app/base/constants/preference/shared_preference_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';


typedef AuthenticationData = (String, String);

@LazySingleton()
class AppPreferences {
  final SharedPreferences _preferences;

  final FlutterSecureStorage _secureStorage;

  AppPreferences(this._preferences, this._secureStorage);

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: SharedPreferenceKeys.accessToken, value: token);
  }

  Future<String> get accessToken async => await _secureStorage.read(key: SharedPreferenceKeys.accessToken) ?? '';

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: SharedPreferenceKeys.refreshToken, value: token);
  }

  Future<String> get refreshToken async => await _secureStorage.read(key: SharedPreferenceKeys.refreshToken) ?? '';

  Future<bool> createSessionTime() async {
    final currentTime = DateTime.now();
    return await _preferences.setInt(SharedPreferenceKeys.sessionTime, currentTime.millisecondsSinceEpoch);
  }

  Future<bool> resetSessionTime() async {
    return await _preferences.setInt(SharedPreferenceKeys.sessionTime, 0);
  }

  Future<bool> isSessionEnd() async {
    final millisecond = _preferences.getInt(SharedPreferenceKeys.sessionTime) ?? 0;
    if (millisecond > 0) {
      final currentTime = DateTime.now();
      final sessionTime = DateTime.fromMillisecondsSinceEpoch(millisecond + ServerRequestResponseConstants.sessionTimeMilli);
      return sessionTime.isBefore(currentTime);
    }
    return true;
  }

  String get getLanguage => _preferences.getString(SharedPreferenceKeys.languageCode) ?? 'en';

  Future<bool> updateLanguage(String lang) async {
    return await _preferences.setString(SharedPreferenceKeys.languageCode, lang);
  }

  Future<String?> get url async => _preferences.getString(SharedPreferenceKeys.url);

  Future<void> setUrl(String url) async {
    await _preferences.setString(SharedPreferenceKeys.url, url);
  }

  Future<bool> setFirstLaunchStatus() async {
    return await _preferences.setBool(SharedPreferenceKeys.isFirstLaunchApp, true);
  }

  bool get isFirstLaunchStatus => _preferences.getBool(SharedPreferenceKeys.isFirstLaunchApp) ?? false;

  Future<(String, String)> get recordAuthentication async {
    final email = await _secureStorage.read(key: SharedPreferenceKeys.email);
    final password = await _secureStorage.read(key: SharedPreferenceKeys.password);
    return Future(() => (email ?? '', password ?? ''));
  }

  Future<void> saveAuthenticationAccount(String email, String password) async {
    await _secureStorage.write(key: SharedPreferenceKeys.email, value: email);
    await _secureStorage.write(key: SharedPreferenceKeys.password, value: password);
  }

  Future<bool> authenticated() async => (await accessToken).isNotEmpty;

  Future<bool> hasRefreshToken() async => (await _secureStorage.read(key: SharedPreferenceKeys.email))?.isNotEmpty ?? false;

  Future<void> clear() async {
    await _secureStorage.write(key: SharedPreferenceKeys.email, value: '');
    await _secureStorage.write(key: SharedPreferenceKeys.password, value: '');
    await _secureStorage.write(key: SharedPreferenceKeys.refreshToken, value: '');
    await _secureStorage.write(key: SharedPreferenceKeys.accessToken, value: '');
    await _preferences.setInt(SharedPreferenceKeys.sessionTime, 0);
  }
}
