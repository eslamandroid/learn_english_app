import 'package:learn_english_app/base/constants/constants.dart';
import 'package:learn_english_app/base/mapper/base_success_mapper/json_array_success_mapper.dart';
import 'package:learn_english_app/base/mapper/base_success_mapper/json_object_success_mapper.dart';


abstract class BaseSuccessResponseMapper<I, O> {
  const BaseSuccessResponseMapper();

  factory BaseSuccessResponseMapper.fromType(SuccessResponseMapperType type) {
    switch (type) {
      case SuccessResponseMapperType.jsonObject:
        return JsonObjectSuccessMapper<I>() as BaseSuccessResponseMapper<I, O>;
      case SuccessResponseMapperType.jsonArray:
        return JsonArraySuccessMapper<I>() as BaseSuccessResponseMapper<I, O>;
    }
  }

  O map(dynamic response, Decoder<I>? decoder);
}
