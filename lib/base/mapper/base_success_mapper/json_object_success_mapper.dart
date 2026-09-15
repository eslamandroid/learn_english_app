import 'package:learn_english_app/base/constants/constants.dart';
import 'package:learn_english_app/base/mapper/base/base_success_response_mapper.dart';

class JsonObjectSuccessMapper<T> extends BaseSuccessResponseMapper<T, T> {
  @override
  T map(response, Decoder<T>? decoder) => decoder != null && response is Map<String, dynamic> ? decoder(response) : response;
}
