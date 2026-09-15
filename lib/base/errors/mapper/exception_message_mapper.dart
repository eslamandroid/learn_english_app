import 'package:learn_english_app/base/errors/base/app_exception.dart';
import 'package:learn_english_app/base/errors/remote/remote_exception.dart';
import 'package:learn_english_app/base/errors/uncaught/app_uncaught_exception.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';
import 'package:learn_english_app/base/utils/utils.dart';
import 'package:learn_english_app/l10n/share_localizations.dart';
import 'package:flutter/material.dart';

class ExceptionMessageMapper {
  final AppLocalizations appLocalizations;

  const ExceptionMessageMapper(this.appLocalizations);

  String map(AppException appException, {String? unknownMessage}) {
    switch (appException.appExceptionType) {
      case AppExceptionType.remote:
        final exception = appException as RemoteException;
        return switch (exception.type) {
          RemoteExceptionType.unAuthentication =>
            appLocalizations.unAuthentication,
          RemoteExceptionType.unAuthorization =>
            exception.serverError?.generalMessage ??
                appLocalizations.unAuthorization,
          RemoteExceptionType.noEntity =>
            exception.serverError?.generalMessage ??
                appLocalizations.notFoundEntity,
          RemoteExceptionType.inputInvalid =>
            exception.serverError?.generalMessage ??
                appLocalizations.invalidInput,
          RemoteExceptionType.badCertificate =>
            appLocalizations.badCertificateException,
          RemoteExceptionType.noInternet =>
            appLocalizations.noInternetException,
          RemoteExceptionType.network => appLocalizations.canNotConnectToHost,
          RemoteExceptionType.serverDefined =>
            exception.generalServerMessage ??
                exception.serverError?.generalMessage ??
                unknownMessage ??
                appLocalizations.serverUnDefined,
          RemoteExceptionType.serverUndefined =>
            exception.generalServerMessage ??
                exception.serverError?.generalMessage ??
                unknownMessage ??
                appLocalizations.serverUnDefined,
          RemoteExceptionType.timeout => appLocalizations.timeoutException,
          RemoteExceptionType.cancellation =>
            appLocalizations.cancellationException,
          RemoteExceptionType.unknown =>
            unknownMessage ?? appLocalizations.unknownException,
          RemoteExceptionType.refreshTokenFailed =>
            appLocalizations.tokenExpired,
        };

      case AppExceptionType.parse:
        return appLocalizations.parseException;
      case AppExceptionType.uncaught:
        final exception = appException as AppUncaughtException;
        return (exception.error is String)
            ? exception.error as String
            : appLocalizations.unknownException;
      case AppExceptionType.validation:
        return appLocalizations.unknownException;
      case AppExceptionType.payment:
        return appLocalizations.unknownException;
    }
  }
}

extension ExceptionMapperEx on BuildContext {
  String exceptionMessage(
    AppException appException, {
    String? unknownMessage,
  }) =>
      localization.let(
        (it) => ExceptionMessageMapper(
          it,
        ).map(appException, unknownMessage: unknownMessage),
      ) ??
      "Oops! Something went wrong";

  bool hasNetworkError(AppException appException) {
    if (appException.appExceptionType == AppExceptionType.remote) {
      final exception = appException as RemoteException;
      return exception.type == RemoteExceptionType.noInternet;
    }

    return false;
  }
}
