

  class AppException implements Exception {
  final AppExceptionType appExceptionType;
  const AppException(this.appExceptionType);
}


enum AppExceptionType {
  remote,
  parse,
  uncaught,
  validation,
  payment
}