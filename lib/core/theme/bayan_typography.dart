import 'package:flutter/material.dart';

import 'bayan_colors.dart';

abstract class BayanTypography {
  static const _displayFontFamily = 'BeVietnamPro';
  static const _bodyFontFamily = 'Inter';
  static const arabicFontFamily = 'Cairo';

  /// Cairo is bundled specifically for Arabic glyph coverage. By listing it
  /// as a fallback on every style, any Arabic codepoint that's missing from
  /// the Latin primary family (BeVietnamPro / Inter) gets rendered with
  /// Cairo automatically — no per-widget changes needed.
  static const _arabicFallback = <String>['Cairo'];

  // ─── Display ───
  static const displayLarge = TextStyle(
    fontFamily: _displayFontFamily,
    fontFamilyFallback: _arabicFallback,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.02 * 32,
  );

  // ─── Headline ───
  static const headlineLarge = TextStyle(
    fontFamily: _displayFontFamily,
    fontFamilyFallback: _arabicFallback,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
  );

  static const headlineMedium = TextStyle(
    fontFamily: _displayFontFamily,
    fontFamilyFallback: _arabicFallback,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  static const headlineLargeMobile = TextStyle(
    fontFamily: _displayFontFamily,
    fontFamilyFallback: _arabicFallback,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
  );

  // ─── Title ───
  static const titleLarge = TextStyle(
    fontFamily: _displayFontFamily,
    fontFamilyFallback: _arabicFallback,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ─── Body ───
  static const bodyLarge = TextStyle(
    fontFamily: _bodyFontFamily,
    fontFamilyFallback: _arabicFallback,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _bodyFontFamily,
    fontFamilyFallback: _arabicFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const bodySmall = TextStyle(
    fontFamily: _bodyFontFamily,
    fontFamilyFallback: _arabicFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  // ─── Label ───
  static const labelLarge = TextStyle(
    fontFamily: _bodyFontFamily,
    fontFamilyFallback: _arabicFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.01 * 14,
  );

  static const labelMedium = TextStyle(
    fontFamily: _bodyFontFamily,
    fontFamilyFallback: _arabicFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
  );

  // ─── Caption ───
  static const caption = TextStyle(
    fontFamily: _bodyFontFamily,
    fontFamilyFallback: _arabicFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: BayanColors.onSurfaceVariant,
  );

  /// Explicit Arabic-first style — for places where the writer KNOWS the
  /// content is Arabic and wants Cairo as the primary family (e.g. the Arabic
  /// branch of [BilingualText]). Use this instead of relying on the fallback
  /// when you want Cairo even for shared Latin glyphs like digits, parens,
  /// punctuation.
  static TextStyle arabic([TextStyle? base]) =>
      (base ?? bodyMedium).copyWith(fontFamily: 'Cairo');

  static TextTheme get textTheme => const TextTheme(
        displayLarge: displayLarge,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        titleLarge: titleLarge,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: caption,
      );
}
