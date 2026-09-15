import 'package:learn_english_app/base/log/config.dart';

 import 'di.dart' as di;

class AppDiConfig extends Config {
  AppDiConfig._();

  factory AppDiConfig.getInstance() {
    return _instance;
  }

  static final AppDiConfig _instance = AppDiConfig._();

  @override
  Future<void> config() async => di.configureInjection();
}
