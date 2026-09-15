import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:learn_english_app/base/network/interceptor/connectivity_interceptor.dart';
import 'package:learn_english_app/base/network/interceptor/custom_log_interceptor.dart';
import 'package:learn_english_app/base/preference/app_preferences.dart';

class ApiClientDefaultSettings {
  const ApiClientDefaultSettings._();

  static List<Interceptor> requiredInterceptors(AppPreferences appPreference) => [
    if (kDebugMode) CustomLogInterceptor(),
    ConnectivityInterceptor(),
  ];

  static List<Interceptor> requiredWithTokenInterceptors(
    Dio dio,
  ) => [
    if (kDebugMode) CustomLogInterceptor(),
    ConnectivityInterceptor(),
  ];
}
