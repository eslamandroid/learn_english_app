import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:learn_english_app/base/errors/remote/server_error_detail.dart';

part 'server_error.freezed.dart';

@freezed
abstract class ServerError with _$ServerError {
  const factory ServerError({
    int? generalServerStatusCode,
    String? generalServerErrorId,
    String? generalMessage,
    @Default(<ServerErrorDetail>[]) List<ServerErrorDetail> errors,

  }) = _ServerError;

}