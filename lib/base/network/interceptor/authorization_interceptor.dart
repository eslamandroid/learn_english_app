import 'package:dio/dio.dart';
import 'package:learn_english_app/base/network/interceptor/base_interceptor.dart';
import 'package:learn_english_app/base/preference/app_preferences.dart';
class AuthorizationInterceptor extends BaseInterceptor {
  final AppPreferences appPreferences;

  AuthorizationInterceptor(this.appPreferences);

  @override
  int get priority => BaseInterceptor.authorizationPriority;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      handler.next(options);
    } catch (error) {
      // if (error is OperationException) {
      //   if (error.graphqlErrors.firstOrNull != null) {
      //     final graphErrors = error.graphqlErrors.first;
      //     final category = graphErrors.extensions?['category'] as String?;
      //     if (category != null) {
      //       if (category == "graphql-authorization") {
      //         appPreferences.resetSessionTime();
      //       }
      //     }
      //   }
      // }
    }
  }
}
