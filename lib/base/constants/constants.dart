// =============================================================================
// APP CONSTANTS - Flutter Project Template
// =============================================================================

// Core app constants
export 'app/app_environment.dart';
export 'app/flavor_extension.dart';

// Environment and configuration
export 'environment/environment_constants.dart';

// Data models and types
export 'model/shared_enum.dart';
export 'model/typedef.dart';

// Preferences and storage
export 'preference/shared_preference_constants.dart';

// Server and API
export 'server/server_request_response_constants.dart';
export 'server/server_timeout_constants.dart';

// =============================================================================
// APP-WIDE CONSTANTS
// =============================================================================

/// App version and build information
class AppVersion {
  static const String version = '1.0.0';
  static const int buildNumber = 1;
  static const String buildName = 'dev';
}

/// App dimensions and sizing
class AppDimensions {
  // Padding and margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;

  // Icon sizes
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;

  // Button heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;
}

/// App animation durations
class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

/// App text styles constants
class AppTextSizes {
  static const double caption = 12.0;
  static const double body = 14.0;
  static const double subtitle = 16.0;
  static const double title = 20.0;
  static const double headline = 24.0;
  static const double display = 32.0;
}

/// App breakpoints for responsive design
class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double wide = 1600;
}