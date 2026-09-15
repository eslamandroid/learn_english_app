
import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_error_detail.freezed.dart';

@freezed
abstract class ServerErrorDetail with _$ServerErrorDetail{
  const factory ServerErrorDetail({
    @Default('') String detail,
    @Default('') String path,

    @Default('') String serverErrorId,

    @Default(-1) int serverStatusCode,

    @Default('') String message,

    @Default('') String field,
}) = _ServerErrorDetails;


}