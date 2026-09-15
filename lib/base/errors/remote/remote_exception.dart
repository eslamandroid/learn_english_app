


import 'package:learn_english_app/base/errors/base/app_exception.dart';
import 'package:learn_english_app/base/errors/remote/server_error.dart';

class RemoteException extends AppException {
  final RemoteExceptionType type;
  final int? httpErrorCode;
  final String? message;
  final ServerError? serverError;
  final Object? rootException;

  const RemoteException({
    required this.type,
    this.httpErrorCode,
    this.message,
    this.serverError,
    this.rootException,
  }) : super(AppExceptionType.remote);

  int get generalServerStatusCode => serverError?.generalServerStatusCode ?? serverError?.errors.firstOrNull?.serverStatusCode ?? -1;

  String? get generalServerErrorId => serverError?.generalServerErrorId ?? serverError?.errors.firstOrNull?.serverErrorId;

  String? get generalServerMessage => serverError?.generalMessage ?? serverError?.errors.firstOrNull?.message;

  @override
  String toString() {
    return '''RemoteException: {
      kind: $type
      httpErrorCode: $httpErrorCode,
      message: $message,
      serverError: $serverError,
      rootException: $rootException,
      generalServerMessage: $generalServerMessage,
      generalServerErrorCode: $generalServerStatusCode,
      generalServerErrorId: $generalServerErrorId,
      stackTrace: ${rootException is Error ? (rootException as Error).stackTrace : ''}
}''';
  }
}

enum RemoteExceptionType {
  noInternet,

  // host not found or cannot connect to host or socket exception
  network,

  // server has defined response
  serverDefined,

  // server has not defined response
  serverUndefined,

  // Caused by an incorrect certification as configured by [ValidateCertificate]
  badCertificate,
  refreshTokenFailed,
  timeout,
  cancellation,
  noEntity,
  unAuthorization,
  unAuthentication,
  inputInvalid,
  unknown
}
