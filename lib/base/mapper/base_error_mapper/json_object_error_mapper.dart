
import 'package:learn_english_app/base/errors/remote/server_error.dart';
import 'package:learn_english_app/base/mapper/base/base_error_response_mapper.dart';

class JsonObjectErrorMapper extends BaseErrorResponseMapper<Map<String, dynamic>> {
  @override
  ServerError mapToEntity(Map<String, dynamic>? data) {
    return ServerError(
      generalServerStatusCode: data?['error']?['status_code'],
      generalServerErrorId: data?['error']?['error_code'],
      generalMessage: data?['error']?['message'],
    );
  }
}
