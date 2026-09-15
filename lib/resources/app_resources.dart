import 'dart:ui';

import 'package:learn_english_app/base/extensions/extensions.dart';

const String iconPath = "assets/icons";
const String imagePath = "assets/images";
const String lottiePath = "assets/lottie";

class AppColor {
  // =============================================================================
  // CUSTOM COLORS
  // =============================================================================

  static const appYellowColor = Color(0xffF5CC9C);
  static const Color appDarkGrayColor = Color(0xff5B5B5B);

  static const Map<int, Color> white = {900: Color(0xffffffff), 800: Color(0xfff9f9f9)};
  static const Map<String, Color> secondary = {
    'green': Color(0xff74F3A3),
    'mid-green': Color(0xff47C375),
    'dark-green': Color(0xff1A9F4B),
    'button-green': Color(0xff128B3E),
    "text-green": Color(0xffC9DED3),
  };

  // =============================================================================
  // PRIMARY COLORS
  // =============================================================================
  static const Color appPrimaryColor = Color(0xFFBE1E2D);
  static const Color appPrimaryLightColor = Color(0xFFF6CDD7);
  static const Color appPrimaryLightColor12 = Color(0xFFF8F8F8);
  static const Color appPrimaryDarkColor = Color(0xff7D7F73);

  // =============================================================================
  // SECONDARY COLORS
  // =============================================================================
  static const Color appSecondaryColor = Color(0xFFA9C27E);
  static const Color appSecondary1Color = Color(0xFFE39953);
  static const Color appSecondary2Color = Color(0xFFE6B579);
  static const Color appVariantColor = Color(0xFFF19F55);

  // =============================================================================
  // BACKGROUND COLORS
  // =============================================================================
  static const Color appBackground = Color(0xFFF9F9F9);
  static const Color appBackground100 = Color(0xFFEFEFEF);
  static const Color appWhite = Color(0xFFFFFFFF);

  // =============================================================================
  // TEXT COLORS
  // =============================================================================
  static const Color appTextColor = Color(0xff231F20);
  static const Color appTextSecondaryColor = Color(0xff515151);
  static const Color appTextThirdColor = Color(0xFF7C7C7C);
  static const Color appBlackColor = Color(0xff171717);
  static const Color appGreyColor = Color(0xff6D6D6D);
  static const Color appDarkColor = Color(0xff6d6d6d);

  // =============================================================================
  // ACCENT COLORS
  // =============================================================================
  static const Color appCeriseColor = Color(0xffCC3362);
  static const Color redColor = Color(0xFFB40000);
  static const Color infoColor = Color(0xffffb793);
  static const Color greenColor = Color(0xFF749700);
  static const Color greenLightColor = Color(0xFF31BD00);

  // =============================================================================
  // OUTLINE & BORDER COLORS
  // =============================================================================
  static const Color outlineColorFade = Color(0x666D6D6D);
  static const Color outlineColor = Color(0xFF989898);

  // =============================================================================
  // NAVIGATION COLORS
  // =============================================================================
  static const Color appNavSelectColor = Color(0xFFCC3362);
  static const Color appNavUnSelectColor = Color(0xFFF2F2F2);

  // =============================================================================
  // PAYMENT & ORDER COLORS
  // =============================================================================
  static const Color paymentCardSelectionColor = Color(0x33F6CDD7);
  static const Color disableIndicatorColor = Color(0xFFF6CDD7);
  static const Color orderPendingColor = Color(0xFFF3F3F3);
  static const Color orderProcessColor = Color(0xFFD7EDFF);
  static const Color orderCompleteColor = Color(0xFFE5F6ED);
  static const Color orderCloseColor = Color(0x1AB40000);
  static const Color orderDetailColor = Color(0xFFC70017);

  // =============================================================================
  // SEMANTIC COLORS
  // =============================================================================

  /// Success color for positive actions
  static const Color success = greenColor;

  /// Warning color for caution actions
  static const Color warning = Color(0xFFFF9800);

  /// Error color for negative actions
  static const Color error = redColor;

  /// Info color for informational content
  static const Color info = Color(0xFF2196F3);

  // =============================================================================
  // NEUTRAL COLORS
  // =============================================================================

  /// Neutral colors for UI elements
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // =============================================================================
  // COLOR UTILITIES
  // =============================================================================

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withAlpha(opacity.toAlpha());
  }

  /// Get color brightness
  static bool isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  /// Get contrasting text color
  static Color getContrastTextColor(Color backgroundColor) {
    return isDark(backgroundColor) ? appWhite : appBlackColor;
  }

  /// Get color variant (lighter or darker)
  static Color getColorVariant(Color color, double factor) {
    if (factor > 1.0) {
      // Make lighter
      return Color.lerp(color, appWhite, (factor - 1.0))!;
    } else {
      // Make darker
      return Color.lerp(color, appBlackColor, (1.0 - factor))!;
    }
  }
}

class AppIcons {
  static String getIconPath(String iconName) {
    if (iconName.startsWith('$iconPath/')) {
      return iconName;
    }
    return '$iconPath/$iconName';
  }

  static bool hasIcon(String iconName) {
    // This would typically check against actual assets
    // For now, return true as placeholder
    return true;
  }
}

class AppImages {
   static const appLogoColored = '$imagePath/app_logo.png';

  static String getImagePath(String imageName) {
    if (imageName.startsWith('$imagePath/')) {
      return imageName;
    }
    return '$imagePath/$imageName';
  }
}

class AppLottie {
  static String getLottiePath(String lottieName) {
    if (lottieName.startsWith('$lottiePath/')) {
      return lottieName;
    }
    return '$lottiePath/$lottieName';
  }
}
