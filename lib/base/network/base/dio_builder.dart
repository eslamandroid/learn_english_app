import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:learn_english_app/base/constants/constants.dart';

class DioBuilder {
  const DioBuilder._();

  static Dio createDio({BaseOptions? options}) {
    final dio = Dio(BaseOptions(
        connectTimeout: options?.connectTimeout ?? ServerTimeoutConstants.connectTimeOut,
        receiveTimeout: options?.receiveTimeout ?? ServerTimeoutConstants.receiveTimeOut,
        sendTimeout: options?.sendTimeout ?? ServerTimeoutConstants.sendTimeOut,
        // followRedirects: true,
        validateStatus: (s) => s != null && s < 500,
        baseUrl: options?.baseUrl ?? AppEnvironment.appApiBaseUrl));

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    return dio;
  }
}
