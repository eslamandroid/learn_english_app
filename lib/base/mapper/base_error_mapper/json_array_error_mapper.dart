
import 'package:learn_english_app/base/errors/remote/server_error.dart';
import 'package:learn_english_app/base/errors/remote/server_error_detail.dart';
import 'package:learn_english_app/base/mapper/base/base_error_response_mapper.dart';


class JsonArrayErrorMapper extends BaseErrorResponseMapper<List<dynamic>> {
  @override
  ServerError mapToEntity(List? data) {
    return ServerError(
        errors: data
                ?.map((jsonObject) => ServerErrorDetail(
                      serverStatusCode: jsonObject['code'],
                      message: jsonObject['message'],
                    ))
                .toList(growable: false) ??
            []);
  }
}
