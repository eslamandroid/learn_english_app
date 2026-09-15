import 'package:learn_english_app/base/errors/remote/server_error.dart';
import 'package:learn_english_app/base/mapper/base/base_error_response_mapper.dart';

class ApiExceptionMapper extends BaseErrorResponseMapper<dynamic> {
  @override
  ServerError mapToEntity(dynamic data) {
    try {
      final result = ApiErrorModel.fromJson(data);
      return ServerError(
        generalMessage: result.message,
        generalServerErrorId: result.exceptionType,
      );
    } catch (_) {
      if (data is Map && data.containsKey("Message")) {
        final message = data["Message"];
         return ServerError(generalMessage: message);
      } else {
        return const ServerError(generalMessage: "Something went wrong");
      }
    }
  }
}

class ApiErrorModel {
  final String message;
  final String exceptionType;
  final String activityId;

  ApiErrorModel({required this.message, required this.exceptionType, required this.activityId});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      message: json['Message'],
      exceptionType: json['ExceptionType'],
      activityId: json['ActivityId'],
    );
  }
}
