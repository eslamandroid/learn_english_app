

import 'package:learn_english_app/base/errors/remote/remote_exception.dart';
import 'package:dio/dio.dart';
import 'package:learn_english_app/base/constants/server/server_request_response_constants.dart';
import 'package:learn_english_app/base/network/interceptor/base_interceptor.dart';
import 'package:learn_english_app/base/preference/app_preferences.dart';

class AccessTokenInterceptor extends BaseInterceptor {
  final AppPreferences _appPreferences;

  AccessTokenInterceptor(this._appPreferences);

  @override
  int get priority => BaseInterceptor.accessTokenPriority;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _appPreferences.accessToken;
    if (token.isNotEmpty) {
      options.headers[ServerRequestResponseConstants.basicAuthorization] = '${ServerRequestResponseConstants.bearer} $token';
    } else {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: const RemoteException(type: RemoteExceptionType.unAuthorization),
        ),
      );
    }
    handler.next(options);
  }
}
