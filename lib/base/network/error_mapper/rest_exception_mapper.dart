import 'dart:io';
import 'package:learn_english_app/base/errors/base/exception_mapper.dart';
import 'package:learn_english_app/base/errors/remote/remote_exception.dart';
import 'package:learn_english_app/base/errors/remote/server_error.dart';
import 'package:dio/dio.dart';
import 'package:learn_english_app/base/mapper/mapper.dart';

class RestExceptionMapper extends ExceptionMapper<RemoteException> {
  RestExceptionMapper(this._errorResponseMapper);

  final BaseErrorResponseMapper _errorResponseMapper;

  @override
  RemoteException map(Object? exception) {
    if (exception is DioException) {
      switch (exception.type) {
        case DioExceptionType.cancel:
          return const RemoteException(type: RemoteExceptionType.cancellation);
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return RemoteException(
            type: RemoteExceptionType.timeout,
            rootException: exception,
          );
        case DioExceptionType.badResponse:
          final httpErrorCode = exception.response?.statusCode ?? -1;

          /// server-defined error
          if (exception.response?.data != null) {
            final serverError = exception.response!.data! is Map
                ? _errorResponseMapper.mapToEntity(exception.response!.data!)
                : ServerError(generalMessage: exception.response!.data!);

            return RemoteException(
              type: RemoteExceptionType.serverDefined,
              httpErrorCode: httpErrorCode,
              serverError: serverError,
            );
          }

          return RemoteException(
            type: RemoteExceptionType.serverUndefined,
            httpErrorCode: httpErrorCode,
            rootException: exception,
          );
        case DioExceptionType.badCertificate:
          return RemoteException(
            type: RemoteExceptionType.badCertificate,
            rootException: exception,
          );
        case DioExceptionType.connectionError:
          return RemoteException(type: RemoteExceptionType.network, rootException: exception);
        case DioExceptionType.unknown:
          if (exception is SocketException) {
            return RemoteException(type: RemoteExceptionType.network, rootException: exception);
          }

          if (exception.error is RemoteException) {
            return exception.error as RemoteException;
          }
      }
    }
    return RemoteException(type: RemoteExceptionType.unknown, rootException: exception);
  }
}
