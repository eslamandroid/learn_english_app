
import 'package:dio/dio.dart';
import 'package:learn_english_app/base/log/log_config.dart';
import 'package:learn_english_app/base/log/log_utils.dart';
import 'package:learn_english_app/base/network/interceptor/base_interceptor.dart';


class CustomLogInterceptor extends BaseInterceptor {
  final bool enableLogRequestInfo;
  final bool enableLogSuccessResponse;
  final bool enableLogErrorResponse;

  CustomLogInterceptor({
    this.enableLogRequestInfo = LogConfig.enableLogRequestInfo,
    this.enableLogSuccessResponse = LogConfig.enableLogSuccessResponse,
    this.enableLogErrorResponse = LogConfig.enableLogErrorResponse,
  });

  static const _enableLogInterceptor = LogConfig.enableLogInterceptor;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_enableLogInterceptor || !enableLogRequestInfo) {
      handler.next(options);
      return;
    }
    final log = <String>[];
    log.add('############# Request ############');
    log.add('🌐 Request: ${options.method} ${options.uri}');
    if (options.headers.isNotEmpty) {
      log.add('🌐 Request Headers:');
      log.add('🌐 ${_mapResponse(options.headers)}');
    }

    if (options.data != null) {
      log.add('🌐 Request Body:');
      if (options.data is FormData) {
        final data = options.data as FormData;
        if (data.fields.isNotEmpty) {
          log.add('🌐 Fields: ${_mapResponse(data.fields)}');
        }
        if (data.files.isNotEmpty) {
          log.add(
            '🌐 Files: ${_mapResponse(data.files.map((e) => MapEntry(e.key, 'File name: ${e.value.filename}, Content type: ${e.value.contentType}, Length: ${e.value.length}')))}',
          );
        }
      } else {
        log.add('🌐 ${_mapResponse(options.data)}');
      }
    }

    Log.d(log.join('\n'));
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_enableLogInterceptor || !enableLogSuccessResponse) {
      handler.next(response);
      return;
    }

    final log = <String>[];
    log.add('############# Response ############');
    log.add('🎉 ${response.requestOptions.method} ${response.requestOptions.uri}');
    log.add('🎉 Request Body: ${_mapResponse(response.requestOptions.data)}');
    log.add('🎉 Success Code: ${response.statusCode}');
    log.add('🎉 ${_mapResponse(response.data)}');
    Log.d(log.join('\n'));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_enableLogInterceptor || !enableLogErrorResponse) {
      handler.next(err);
      return;
    }

    final log = <String>[];

    log.add('############# Error ############');
    log.add(err.toString());
    log.add('⛔️ ${err.requestOptions.method} ${err.requestOptions.uri}');
    log.add('⛔️ Error Code: ${err.response?.statusCode ?? 'unknown status code'}');
    log.add('⛔️ Json: ${err.response}');
    Log.e(log.join('\n'));
    handler.next(err);
  }


  String _mapResponse(dynamic data) {
    if (data is Map) {
      return Log.prettyJson(data as Map<String, dynamic>);
    }
    return data.toString();
  }

  @override
  int get priority => BaseInterceptor.customLogPriority;
}
