

import 'package:learn_english_app/base/errors/base/app_exception.dart';

class AppUncaughtException extends AppException {
  final Object? error;

  const AppUncaughtException(this.error) : super(AppExceptionType.uncaught);

  @override
  String toString() {
    return '${error?.toString()}';
  }
}
