import 'package:learn_english_app/base/constants/constants.dart';
import 'package:learn_english_app/base/errors/remote/server_error.dart';
import 'package:learn_english_app/base/mapper/base_error_mapper/json_array_error_mapper.dart';
import 'package:learn_english_app/base/mapper/base_error_mapper/json_object_error_mapper.dart';

import 'base_data_mapper.dart';

abstract class BaseErrorResponseMapper<T> extends BaseDataMapper<T, ServerError> {
  const BaseErrorResponseMapper();

  factory BaseErrorResponseMapper.fromType(ErrorResponseMapperType type) {
    switch (type) {
      case ErrorResponseMapperType.jsonObject:
        return JsonObjectErrorMapper() as BaseErrorResponseMapper<T>;

      case ErrorResponseMapperType.jsonArray:
        return JsonArrayErrorMapper() as BaseErrorResponseMapper<T>;
    }
  }
}
