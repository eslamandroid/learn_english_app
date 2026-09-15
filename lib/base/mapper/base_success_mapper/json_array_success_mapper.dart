import 'package:learn_english_app/base/constants/constants.dart';
import 'package:learn_english_app/base/mapper/base/base_success_response_mapper.dart';


class JsonArraySuccessMapper<T> extends BaseSuccessResponseMapper<T, List<T>> {
  @override
  List<T> map(response, Decoder<T>? decoder) =>
      decoder != null && response is List ? response.map((jsonObject) => decoder(jsonObject)).toList(growable: false) : [response];
}
