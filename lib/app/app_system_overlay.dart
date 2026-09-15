import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_english_app/resources/app_resources.dart';

class AppSystemOverlay {
  final ColorScheme colorScheme;

  AppSystemOverlay(this.colorScheme);

  void init() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.appPrimaryColor,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColor.appPrimaryColor,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  void reset() {
    init();
  }

  SystemUiOverlayStyle transparentWithWhiteBottom() {
    final systemUi = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: colorScheme.brightness == Brightness.light ? Colors.white : colorScheme.surface,
        systemNavigationBarContrastEnforced: true,
        systemNavigationBarIconBrightness: Brightness.dark);
    SystemChrome.setSystemUIOverlayStyle(systemUi);
    return systemUi;
  }


  SystemUiOverlayStyle transparent() {
    final systemUi = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.light);
    SystemChrome.setSystemUIOverlayStyle(systemUi);
    return systemUi;
  }



}