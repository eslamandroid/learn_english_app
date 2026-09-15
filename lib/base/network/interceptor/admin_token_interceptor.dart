import 'package:dio/dio.dart';
import 'package:learn_english_app/base/constants/constants.dart';
import 'package:learn_english_app/base/network/interceptor/base_interceptor.dart';
import 'package:learn_english_app/base/preference/app_preferences.dart';

class AdminTokenInterceptor extends BaseInterceptor {

  @override
  int get priority => BaseInterceptor.accessTokenPriority;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {

    options.headers[ServerRequestResponseConstants.basicAuthorization] =
        '${ServerRequestResponseConstants.bearer} ${environment.adminToken}';
    options.headers[ServerRequestResponseConstants.store] = AppEnvironment.store;
    handler.next(options);
  }
}
