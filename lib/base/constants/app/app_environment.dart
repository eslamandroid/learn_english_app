
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learn_english_app/base/constants/model/shared_enum.dart';

import 'flavor_extension.dart';

late AppEnvironment environment;

class AppEnvironment {
  final Flavor type;
  final String baseUrl;
  final String adminToken;
  final String payfortUrl;
  final String payfortAccessCode;
  final String payfortMerchant;
  final String payfortShaRequest;
  final String tabbyPublicKey;
  final String tabbyMerchant;

  AppEnvironment._(
      {required this.type,
      required this.baseUrl,
      required this.adminToken,
      required this.payfortUrl,
      required this.payfortAccessCode,
      required this.payfortMerchant,
      required this.payfortShaRequest,
      required this.tabbyPublicKey,
      required this.tabbyMerchant});

  factory AppEnvironment.initialize(Flavor type) {
    String getEnv(String key) {
      final value = dotenv.env[key];
      if (value == null || value.isEmpty) {
        throw ArgumentError('Missing environment variable: $key');
      }
      return value;
    }

    return AppEnvironment._(
      type: type,
      baseUrl: getEnv(type.baseUrlKey),
      adminToken: getEnv(type.adminTokenKey),
      payfortUrl: getEnv(type.payfortUrlKey),
      payfortAccessCode: getEnv(type.payfortAccessCodeKey),
      payfortMerchant: getEnv(type.payfortMerchantKey),
      payfortShaRequest: getEnv(type.payfortShaRequestKey),
      tabbyPublicKey: getEnv(type.tabbyPublicKey),
      tabbyMerchant: getEnv(type.tabbyMerchantKey),
    );
  }

  static Flavor fromEnvironment() {
    const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
    switch (flavor) {
      case 'staging':
        return Flavor.staging;
      case 'prod':
        return Flavor.prod;
      default:
        return Flavor.dev;
    }
  }

  static String get appApiBaseUrl => environment.baseUrl;

  static String get tabbyMerchantKey => AppEnvironment.tabbyMerchantKey;

  static String get googleMapApiKey => "";

  static get store => "ksa_arabic";

}

void initEnvironment(){
  const String flavor = String.fromEnvironment('FLAVOR',defaultValue: 'prod');
  switch (flavor) {
    case 'staging':
      environment = AppEnvironment.initialize(Flavor.staging);
      break;
    case 'prod':
      environment = AppEnvironment.initialize(Flavor.prod);
      break;
    default:
      environment = AppEnvironment.initialize(Flavor.dev);
  }
}