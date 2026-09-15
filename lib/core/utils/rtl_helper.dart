import 'package:flutter/material.dart';

abstract class RtlHelper {
  static bool isRtl(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl;

  static bool isLocaleRtl(Locale locale) =>
      _rtlLanguageCodes.contains(locale.languageCode);

  static const _rtlLanguageCodes = {'ar', 'fa', 'he', 'ur'};

  static TextDirection directionFor(Locale locale) =>
      isLocaleRtl(locale) ? TextDirection.rtl : TextDirection.ltr;
}
