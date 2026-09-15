




import 'package:learn_english_app/base/constants/model/shared_enum.dart';

extension FlavorEnv on Flavor {
  String get baseUrlKey => switch (this) {
    Flavor.dev => 'DEVELOPMENT_BASE_URL',
    Flavor.staging => 'STAGING3_BASE_URL',
    Flavor.prod => 'PRODUCTION_BASE_URL',
  };

  String get adminTokenKey => switch (this) {
    Flavor.dev => 'DEV_BEARER_TOKEN',
    Flavor.staging => 'STG3_BEARER_TOKEN',
    Flavor.prod => 'BEARER_TOKEN',
  };

  String get payfortUrlKey => switch (this) {
    Flavor.prod => 'PAYFORT_PRODUCTION_PAYMENT_URL',
    _ => 'PAYFORT_SANDBOX_PAYMENT_URL',
  };

  String get payfortAccessCodeKey => switch (this) {
    Flavor.prod => 'ACCESS_CODE',
    _ => 'STAGING_ACCESS_CODE',
  };

  String get payfortMerchantKey => switch (this) {
    Flavor.prod => 'MERCHANT_IDENTIFIER',
    _ => 'STAGING_MERCHANT_IDENTIFIER',
  };

  String get payfortShaRequestKey => switch (this) {
    Flavor.prod => 'SHA_REQUEST_PHRASE',
    _ => 'STAGING_SHA_REQUEST_PHRASE',
  };

  String get tabbyPublicKey => switch (this) {
    Flavor.prod => 'TABBY_PUBLIC_KEY',
    _ => 'TABBY_PUBLIC_TEST_KEY',
  };

  String get tabbyMerchantKey => 'TABBY_MERCHANT_CODE';
}