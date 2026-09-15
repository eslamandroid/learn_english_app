// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_error_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerErrorDetail {

 String get detail; String get path; String get serverErrorId; int get serverStatusCode; String get message; String get field;
/// Create a copy of ServerErrorDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerErrorDetailCopyWith<ServerErrorDetail> get copyWith => _$ServerErrorDetailCopyWithImpl<ServerErrorDetail>(this as ServerErrorDetail, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerErrorDetail&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.path, path) || other.path == path)&&(identical(other.serverErrorId, serverErrorId) || other.serverErrorId == serverErrorId)&&(identical(other.serverStatusCode, serverStatusCode) || other.serverStatusCode == serverStatusCode)&&(identical(other.message, message) || other.message == message)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,detail,path,serverErrorId,serverStatusCode,message,field);

@override
String toString() {
  return 'ServerErrorDetail(detail: $detail, path: $path, serverErrorId: $serverErrorId, serverStatusCode: $serverStatusCode, message: $message, field: $field)';
}


}

/// @nodoc
abstract mixin class $ServerErrorDetailCopyWith<$Res>  {
  factory $ServerErrorDetailCopyWith(ServerErrorDetail value, $Res Function(ServerErrorDetail) _then) = _$ServerErrorDetailCopyWithImpl;
@useResult
$Res call({
 String detail, String path, String serverErrorId, int serverStatusCode, String message, String field
});




}
/// @nodoc
class _$ServerErrorDetailCopyWithImpl<$Res>
    implements $ServerErrorDetailCopyWith<$Res> {
  _$ServerErrorDetailCopyWithImpl(this._self, this._then);

  final ServerErrorDetail _self;
  final $Res Function(ServerErrorDetail) _then;

/// Create a copy of ServerErrorDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? detail = null,Object? path = null,Object? serverErrorId = null,Object? serverStatusCode = null,Object? message = null,Object? field = null,}) {
  return _then(_self.copyWith(
detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,serverErrorId: null == serverErrorId ? _self.serverErrorId : serverErrorId // ignore: cast_nullable_to_non_nullable
as String,serverStatusCode: null == serverStatusCode ? _self.serverStatusCode : serverStatusCode // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc


class _ServerErrorDetails implements ServerErrorDetail {
  const _ServerErrorDetails({this.detail = '', this.path = '', this.serverErrorId = '', this.serverStatusCode = -1, this.message = '', this.field = ''});
  

@override@JsonKey() final  String detail;
@override@JsonKey() final  String path;
@override@JsonKey() final  String serverErrorId;
@override@JsonKey() final  int serverStatusCode;
@override@JsonKey() final  String message;
@override@JsonKey() final  String field;

/// Create a copy of ServerErrorDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerErrorDetailsCopyWith<_ServerErrorDetails> get copyWith => __$ServerErrorDetailsCopyWithImpl<_ServerErrorDetails>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerErrorDetails&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.path, path) || other.path == path)&&(identical(other.serverErrorId, serverErrorId) || other.serverErrorId == serverErrorId)&&(identical(other.serverStatusCode, serverStatusCode) || other.serverStatusCode == serverStatusCode)&&(identical(other.message, message) || other.message == message)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,detail,path,serverErrorId,serverStatusCode,message,field);

@override
String toString() {
  return 'ServerErrorDetail(detail: $detail, path: $path, serverErrorId: $serverErrorId, serverStatusCode: $serverStatusCode, message: $message, field: $field)';
}


}

/// @nodoc
abstract mixin class _$ServerErrorDetailsCopyWith<$Res> implements $ServerErrorDetailCopyWith<$Res> {
  factory _$ServerErrorDetailsCopyWith(_ServerErrorDetails value, $Res Function(_ServerErrorDetails) _then) = __$ServerErrorDetailsCopyWithImpl;
@override @useResult
$Res call({
 String detail, String path, String serverErrorId, int serverStatusCode, String message, String field
});




}
/// @nodoc
class __$ServerErrorDetailsCopyWithImpl<$Res>
    implements _$ServerErrorDetailsCopyWith<$Res> {
  __$ServerErrorDetailsCopyWithImpl(this._self, this._then);

  final _ServerErrorDetails _self;
  final $Res Function(_ServerErrorDetails) _then;

/// Create a copy of ServerErrorDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? detail = null,Object? path = null,Object? serverErrorId = null,Object? serverStatusCode = null,Object? message = null,Object? field = null,}) {
  return _then(_ServerErrorDetails(
detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,serverErrorId: null == serverErrorId ? _self.serverErrorId : serverErrorId // ignore: cast_nullable_to_non_nullable
as String,serverStatusCode: null == serverStatusCode ? _self.serverStatusCode : serverStatusCode // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
