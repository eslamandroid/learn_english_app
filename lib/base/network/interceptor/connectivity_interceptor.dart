import 'package:learn_english_app/base/errors/remote/remote_exception.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:learn_english_app/base/network/interceptor/base_interceptor.dart';

@Injectable()
class ConnectivityInterceptor extends BaseInterceptor {
  @override
  int get priority => BaseInterceptor.connectivityPriority;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: const RemoteException(type: RemoteExceptionType.noInternet),
        ),
      );
    }

    return super.onRequest(options, handler);
  }
}
