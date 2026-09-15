// =============================================================================
// THEMES - Flutter Project Template
// =============================================================================

import 'dart:ui';

import 'package:google_fonts/google_fonts.dart';
import 'package:learn_english_app/base/constants/constants.dart';
import 'package:flutter/material.dart';

import 'app_resources.dart';

// =============================================================================
// THEME FACTORY
// =============================================================================

/// Professional theme factory for the application
class AppThemeFactory {
  /// Get the main theme data
  static ThemeData getMainTheme(BuildContext context) {
    return _buildMainTheme(context);
  }

  /// Get light theme data
  static ThemeData getLightTheme(BuildContext context) {
    return _buildLightTheme(context);
  }

  /// Get dark theme data
  static ThemeData getDarkTheme(BuildContext context) {
    return _buildDarkTheme(context);
  }

  /// Get theme by name
  static ThemeData getThemeByName(BuildContext context, String themeName) {
    switch (themeName.toLowerCase()) {
      case 'light':
        return getLightTheme(context);
      case 'dark':
        return getDarkTheme(context);
      default:
        return getMainTheme(context);
    }
  }
}

// =============================================================================
// MAIN THEME BUILDER
// =============================================================================

/// Build the main application theme
ThemeData _buildMainTheme(BuildContext context) {
  return ThemeData(
    // =============================================================================
    // COLOR SCHEME
    // =============================================================================
    colorScheme: _buildColorScheme(),

    // =============================================================================
    // MATERIAL 3
    // =============================================================================
    useMaterial3: true,

    // =============================================================================
    // TYPOGRAPHY
    // =============================================================================
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme),
    // _buildTextTheme(),

    // =============================================================================
    // COMPONENT THEMES
    // =============================================================================
    appBarTheme: _buildAppBarTheme(),
    drawerTheme: _buildDrawerTheme(),
    bottomNavigationBarTheme: _buildBottomNavigationBarTheme(),
    bottomSheetTheme: _buildBottomSheetTheme(),
    cardTheme: _buildCardTheme(),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    outlinedButtonTheme: _buildOutlinedButtonTheme(),
    textButtonTheme: _buildTextButtonTheme(),
    inputDecorationTheme: _buildInputDecorationTheme(),
    dividerTheme: _buildDividerTheme(),
    iconTheme: _buildIconTheme(),

    // =============================================================================
    // LAYOUT & SPACING
    // =============================================================================
    scaffoldBackgroundColor: AppColor.appBackground,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,

    // =============================================================================
    // FONTS
    // =============================================================================
    fontFamily: 'Cairo',

    // =============================================================================
    // CUSTOM PROPERTIES
    // =============================================================================
    extensions: [
      _CustomThemeExtension(
        borderRadius: AppDimensions.radiusM,
        shadowColor: AppColor.neutral200,
        animationDuration: AppDurations.normal,
      ),
    ],
  );
}

// =============================================================================
// COLOR SCHEME BUILDER
// =============================================================================

/// Build the color scheme for the theme
ColorScheme _buildColorScheme() {
  return ColorScheme(
    brightness: Brightness.light,

    // Primary colors
    primary: AppColor.appPrimaryColor,
    onPrimary: AppColor.appWhite,
    primaryContainer: AppColor.appPrimaryLightColor,
    onPrimaryContainer: AppColor.appPrimaryColor,

    // Secondary colors
    secondary: AppColor.appSecondaryColor,
    onSecondary: AppColor.appBlackColor,
    secondaryContainer: AppColor.appSecondary1Color,
    onSecondaryContainer: AppColor.appWhite,

    // Surface colors
    surface: AppColor.appBackground,
    onSurface: AppColor.appTextColor,
    surfaceVariant: AppColor.appBackground100,
    onSurfaceVariant: AppColor.appTextSecondaryColor,

    // Background colors
    background: AppColor.appBackground,
    onBackground: AppColor.appTextColor,

    // Error colors
    error: AppColor.error,
    onError: AppColor.appWhite,
    errorContainer: AppColor.error.withOpacity(0.1),
    onErrorContainer: AppColor.error,

    // Outline colors
    outline: AppColor.outlineColor,
    outlineVariant: AppColor.outlineColorFade,

    // Shadow colors
    shadow: AppColor.neutral200,
    scrim: AppColor.neutral900.withOpacity(0.5),

    // Inverse colors
    inversePrimary: AppColor.appWhite,
    inverseSurface: AppColor.appBlackColor,
    onInverseSurface: AppColor.appWhite,
  );
}

// =============================================================================
// TYPOGRAPHY BUILDER
// =============================================================================

/// Build the text theme for the application
TextTheme _buildTextTheme() {
  return TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontSize: AppTextSizes.display,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: AppTextSizes.headline,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
    ),
    displaySmall: TextStyle(
      fontSize: AppTextSizes.title,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontSize: AppTextSizes.headline,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
    ),
    headlineMedium: TextStyle(
      fontSize: AppTextSizes.title,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: AppTextSizes.subtitle,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),

    // Title styles
    titleLarge: TextStyle(
      fontSize: AppTextSizes.title,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: AppTextSizes.subtitle,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: AppTextSizes.body,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
    ),

    // Body styles
    bodyLarge: TextStyle(
      fontSize: AppTextSizes.body,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
    ),
    bodyMedium: TextStyle(
      fontSize: AppTextSizes.body,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: AppTextSizes.caption,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),

    // Label styles
    labelLarge: TextStyle(
      fontSize: AppTextSizes.body,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: AppTextSizes.caption,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: AppTextSizes.caption,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
  ).apply(bodyColor: AppColor.appTextColor, displayColor: AppColor.appTextColor);
}

// =============================================================================
// COMPONENT THEME BUILDERS
// =============================================================================

/// Build the app bar theme
AppBarTheme _buildAppBarTheme() {
  return AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColor.appTextColor,
    elevation: 0,
    scrolledUnderElevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: AppTextSizes.title,
      fontWeight: FontWeight.w600,
      color: AppColor.appTextColor,
    ),
    iconTheme: IconThemeData(color: AppColor.appTextColor, size: AppDimensions.iconSizeM),
  );
}

DrawerThemeData _buildDrawerTheme() {
  return DrawerThemeData(backgroundColor: AppColor.white[900]);
}

/// Build the bottom navigation bar theme
BottomNavigationBarThemeData _buildBottomNavigationBarTheme() {
  return BottomNavigationBarThemeData(
    backgroundColor: AppColor.appWhite,
    selectedItemColor: AppColor.appPrimaryColor,
    unselectedItemColor: AppColor.appTextSecondaryColor,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: AppTextSizes.caption,
      color: AppColor.appPrimaryColor,
    ),
    unselectedLabelStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: AppTextSizes.caption,
      color: AppColor.appTextSecondaryColor,
    ),
  );
}

/// Build the bottom sheet theme
BottomSheetThemeData _buildBottomSheetTheme() {
  return BottomSheetThemeData(
    backgroundColor: AppColor.appWhite,
    modalBackgroundColor: AppColor.appWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppDimensions.radiusL),
        topRight: Radius.circular(AppDimensions.radiusL),
      ),
    ),
    elevation: 16,
    modalElevation: 16,
  );
}

/// Build the card theme
CardThemeData _buildCardTheme() {
  return CardThemeData(
    color: AppColor.appWhite,
    elevation: 2,
    shadowColor: AppColor.neutral200,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
    margin: EdgeInsets.all(AppDimensions.paddingS),
  );
}

/// Build the elevated button theme
ElevatedButtonThemeData _buildElevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColor.appPrimaryColor,
      foregroundColor: AppColor.appWhite,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
      textStyle: TextStyle(fontSize: AppTextSizes.body, fontWeight: FontWeight.w600),
    ),
  );
}

/// Build the outlined button theme
OutlinedButtonThemeData _buildOutlinedButtonTheme() {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColor.appPrimaryColor,
      side: BorderSide(color: AppColor.appPrimaryColor, width: 1.5),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
      textStyle: TextStyle(fontSize: AppTextSizes.body, fontWeight: FontWeight.w600),
    ),
  );
}

/// Build the text button theme
TextButtonThemeData _buildTextButtonTheme() {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColor.appPrimaryColor,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      textStyle: TextStyle(fontSize: AppTextSizes.body, fontWeight: FontWeight.w600),
    ),
  );
}

/// Build the input decoration theme
InputDecorationTheme _buildInputDecorationTheme() {
  return InputDecorationTheme(
    filled: true,
    fillColor: AppColor.appWhite,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      borderSide: BorderSide(color: AppColor.outlineColorFade, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      borderSide: BorderSide(color: AppColor.outlineColorFade, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      borderSide: BorderSide(color: AppColor.appPrimaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      borderSide: BorderSide(color: AppColor.error, width: 1),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingM,
      vertical: AppDimensions.paddingM,
    ),
    labelStyle: TextStyle(color: AppColor.appTextSecondaryColor, fontSize: AppTextSizes.body),
    hintStyle: TextStyle(color: AppColor.appTextThirdColor, fontSize: AppTextSizes.body),
  );
}

/// Build the divider theme
DividerThemeData _buildDividerTheme() {
  return DividerThemeData(
    color: AppColor.outlineColorFade,
    thickness: 1,
    space: AppDimensions.paddingM,
  );
}

/// Build the icon theme
IconThemeData _buildIconTheme() {
  return IconThemeData(color: AppColor.appTextColor, size: AppDimensions.iconSizeM);
}

// =============================================================================
// LIGHT THEME BUILDER
// =============================================================================

/// Build the light theme
ThemeData _buildLightTheme(BuildContext context) {
  return _buildMainTheme(context).copyWith(
    brightness: Brightness.light,
    colorScheme: _buildColorScheme().copyWith(brightness: Brightness.light),
  );
}

// =============================================================================
// DARK THEME BUILDER
// =============================================================================

/// Build the dark theme
ThemeData _buildDarkTheme(BuildContext context) {
  return _buildMainTheme(context).copyWith(
    brightness: Brightness.dark,
    colorScheme: _buildColorScheme().copyWith(
      brightness: Brightness.dark,
      surface: AppColor.neutral900,
      onSurface: AppColor.appWhite,
      background: AppColor.neutral800,
      onBackground: AppColor.appWhite,
    ),
    scaffoldBackgroundColor: AppColor.neutral800,
  );
}

// =============================================================================
// CUSTOM THEME EXTENSION
// =============================================================================

/// Custom theme extension for additional properties
class _CustomThemeExtension extends ThemeExtension<_CustomThemeExtension> {
  final double borderRadius;
  final Color shadowColor;
  final Duration animationDuration;

  const _CustomThemeExtension({
    required this.borderRadius,
    required this.shadowColor,
    required this.animationDuration,
  });

  @override
  _CustomThemeExtension copyWith({
    double? borderRadius,
    Color? shadowColor,
    Duration? animationDuration,
  }) {
    return _CustomThemeExtension(
      borderRadius: borderRadius ?? this.borderRadius,
      shadowColor: shadowColor ?? this.shadowColor,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  static Duration _lerpDuration(Duration a, Duration b, double t) {
    final us = (a.inMicroseconds + (b.inMicroseconds - a.inMicroseconds) * t).round();
    return Duration(microseconds: us);
  }

  @override
  _CustomThemeExtension lerp(covariant ThemeExtension<_CustomThemeExtension>? other, double t) {
    if (other is! _CustomThemeExtension) {
      return this;
    }

    return _CustomThemeExtension(
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t) ?? borderRadius,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
      animationDuration: _lerpDuration(animationDuration, other.animationDuration, t),
    );
  }
}

// =============================================================================
// THEME UTILITIES
// =============================================================================

/// Theme utility functions
class ThemeUtils {
  /// Get custom theme extension
  static _CustomThemeExtension getCustomTheme(BuildContext context) {
    return Theme.of(context).extension<_CustomThemeExtension>() ??
        const _CustomThemeExtension(
          borderRadius: 8.0,
          shadowColor: Colors.black12,
          animationDuration: Duration(milliseconds: 300),
        );
  }

  /// Check if current theme is dark
  static bool isDarkTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get appropriate text color for background
  static Color getTextColorForBackground(BuildContext context, Color backgroundColor) {
    return AppColor.getContrastTextColor(backgroundColor);
  }

  /// Get theme-aware color
  static Color getThemeAwareColor(BuildContext context, Color lightColor, Color darkColor) {
    return isDarkTheme(context) ? darkColor : lightColor;
  }
}

// =============================================================================
// LEGACY SUPPORT
// =============================================================================

/// Legacy function for backward compatibility
@Deprecated('Use AppThemeFactory.getMainTheme() instead')
ThemeData themesData(BuildContext context) => AppThemeFactory.getMainTheme(context);
