import 'dart:async';

import 'package:learn_english_app/base/errors/base/app_exception.dart';

class AppExceptionWrapper {
  final AppException appException;
  final Completer<void>? exceptionCompleter;
  final Future<void> Function()? doOnRetry;
  final String? overrideMessage;

  AppExceptionWrapper({
    required this.appException,
    this.exceptionCompleter,
    this.doOnRetry,
    this.overrideMessage,
  });

  @override
  String toString() {
    return 'AppExceptionWrapper(appException: $appException, exceptionCompleter: $exceptionCompleter, doOnRetry: $doOnRetry, overrideMessage: $overrideMessage)';
  }
}
