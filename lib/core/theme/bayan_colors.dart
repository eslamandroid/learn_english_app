import 'package:flutter/material.dart';

abstract class BayanColors {
  // ─── Primary ───
  static const primary              = Color(0xFF0058BE);
  static const onPrimary            = Color(0xFFFFFFFF);
  static const primaryContainer     = Color(0xFF2170E4);
  static const onPrimaryContainer   = Color(0xFFFEFCFF);
  static const inversePrimary       = Color(0xFFADC6FF);
  static const primaryFixed         = Color(0xFFD8E2FF);
  static const primaryFixedDim      = Color(0xFFADC6FF);
  static const onPrimaryFixed       = Color(0xFF001A42);
  static const onPrimaryFixedVariant = Color(0xFF004395);
  static const white = Color(0xFFFFFFFF);

  // ─── Secondary ───
  static const secondary            = Color(0xFF006C49);
  static const onSecondary          = Color(0xFFFFFFFF);
  static const secondaryContainer   = Color(0xFF6CF8BB);
  static const onSecondaryContainer = Color(0xFF00714D);
  static const secondaryFixed       = Color(0xFF6FFBBE);
  static const secondaryFixedDim    = Color(0xFF4EDEA3);
  static const onSecondaryFixed     = Color(0xFF002113);
  static const onSecondaryFixedVariant = Color(0xFF005236);

  // ─── Tertiary ───
  static const tertiary             = Color(0xFF825100);
  static const onTertiary           = Color(0xFFFFFFFF);
  static const tertiaryContainer    = Color(0xFFA36700);
  static const onTertiaryContainer  = Color(0xFFFFFBFF);
  static const tertiaryFixed        = Color(0xFFFFDDB8);
  static const tertiaryFixedDim     = Color(0xFFFFB95F);
  static const onTertiaryFixed      = Color(0xFF2A1700);
  static const onTertiaryFixedVariant = Color(0xFF653E00);

  // ─── Surface ───
  static const surface              = Color(0xFFF8F9FF);
  static const surfaceDim           = Color(0xFFCBDBF5);
  static const surfaceBright        = Color(0xFFF8F9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow  = Color(0xFFEFF4FF);
  static const surfaceContainer     = Color(0xFFE5EEFF);
  static const surfaceContainerHigh = Color(0xFFDCE9FF);
  static const surfaceContainerHighest = Color(0xFFD3E4FE);
  static const surfaceVariant       = Color(0xFFD3E4FE);
  static const surfaceTint          = Color(0xFF005AC2);

  static const onSurface            = Color(0xFF0B1C30);
  static const onSurfaceVariant     = Color(0xFF424754);
  static const inverseSurface       = Color(0xFF213145);
  static const inverseOnSurface     = Color(0xFFEAF1FF);

  // ─── Background ───
  static const background           = Color(0xFFF8F9FF);
  static const onBackground         = Color(0xFF0B1C30);

  // ─── Outline ───
  static const outline              = Color(0xFF727785);
  static const outlineVariant       = Color(0xFFC2C6D6);

  // ─── Error ───
  static const error                = Color(0xFFBA1A1A);
  static const onError              = Color(0xFFFFFFFF);
  static const errorContainer       = Color(0xFFFFDAD6);
  static const onErrorContainer     = Color(0xFF93000A);

  // ─── Status (semantic) ───
  static const success              = Color(0xFF22C55E);
  static const warning              = Color(0xFFF59E0B);

  // ─── Text aliases ───
  static const textPrimary          = onSurface;
  static const textSecondary        = onSurfaceVariant;
  static const textOnPrimary        = onPrimary;

  // ─── CEFR Level Colors ───
  static const a1Color = Color(0xFF22C55E);
  static const a2Color = Color(0xFF3B82F6);
  static const b1Color = Color(0xFFF59E0B);
  static const b2Color = Color(0xFFEF4444);
  static const c1Color = Color(0xFF8B5CF6);
  static const c2Color = Color(0xFFEC4899);
}
