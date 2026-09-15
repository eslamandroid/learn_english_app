import 'package:flutter/material.dart';

import 'bayan_colors.dart';
import 'bayan_typography.dart';

abstract class BayanTheme {
  static ThemeData light() {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: BayanColors.primary,
      onPrimary: BayanColors.onPrimary,
      primaryContainer: BayanColors.primaryContainer,
      onPrimaryContainer: BayanColors.onPrimaryContainer,
      inversePrimary: BayanColors.inversePrimary,
      secondary: BayanColors.secondary,
      onSecondary: BayanColors.onSecondary,
      secondaryContainer: BayanColors.secondaryContainer,
      onSecondaryContainer: BayanColors.onSecondaryContainer,
      tertiary: BayanColors.tertiary,
      onTertiary: BayanColors.onTertiary,
      tertiaryContainer: BayanColors.tertiaryContainer,
      onTertiaryContainer: BayanColors.onTertiaryContainer,
      error: BayanColors.error,
      onError: BayanColors.onError,
      errorContainer: BayanColors.errorContainer,
      onErrorContainer: BayanColors.onErrorContainer,
      surface: BayanColors.surface,
      onSurface: BayanColors.onSurface,
      onSurfaceVariant: BayanColors.onSurfaceVariant,
      inverseSurface: BayanColors.inverseSurface,
      onInverseSurface: BayanColors.inverseOnSurface,
      outline: BayanColors.outline,
      outlineVariant: BayanColors.outlineVariant,
      surfaceTint: BayanColors.surfaceTint,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'BeVietnamPro',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BayanColors.background,

      // textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
      //   bodyColor: BayanColors.onSurface,
      //   displayColor: BayanColors.onSurface,
      // ),
      textTheme: BayanTypography.textTheme.apply(bodyColor: BayanColors.onSurface, displayColor: BayanColors.onSurface),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: BayanColors.onSurface,
        elevation: 1,
        scrolledUnderElevation: 0,
        surfaceTintColor: BayanColors.white,
        centerTitle: true,
        titleTextStyle: BayanTypography.titleLarge,
        iconTheme: IconThemeData(color: BayanColors.onSurface),
      ),
      cardTheme: CardThemeData(
        color: BayanColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BayanColors.primary,
          foregroundColor: BayanColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: BayanTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BayanColors.primary,
          side: const BorderSide(color: BayanColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: BayanTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: BayanColors.primary, textStyle: BayanTypography.labelLarge),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BayanColors.surfaceContainerLowest,
        selectedItemColor: BayanColors.primary,
        unselectedItemColor: BayanColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: BayanColors.surfaceContainerLowest,
        modalBackgroundColor: BayanColors.surfaceContainerLowest,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BayanColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BayanColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BayanColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BayanColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BayanColors.error),
        ),
      ),
      dividerTheme: const DividerThemeData(color: BayanColors.outlineVariant, thickness: 1, space: 16),
      iconTheme: const IconThemeData(color: BayanColors.onSurface, size: 24),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
