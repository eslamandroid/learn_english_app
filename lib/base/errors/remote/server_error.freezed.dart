// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerError {

 int? get generalServerStatusCode; String? get generalServerErrorId; String? get generalMessage; List<ServerErrorDetail> get errors;
/// Create a copy of ServerError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerErrorCopyWith<ServerError> get copyWith => _$ServerErrorCopyWithImpl<ServerError>(this as ServerError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerError&&(identical(other.generalServerStatusCode, generalServerStatusCode) || other.generalServerStatusCode == generalServerStatusCode)&&(identical(other.generalServerErrorId, generalServerErrorId) || other.generalServerErrorId == generalServerErrorId)&&(identical(other.generalMessage, generalMessage) || other.generalMessage == generalMessage)&&const DeepCollectionEquality().equals(other.errors, errors));
}


@override
int get hashCode => Object.hash(runtimeType,generalServerStatusCode,generalServerErrorId,generalMessage,const DeepCollectionEquality().hash(errors));

@override
String toString() {
  return 'ServerError(generalServerStatusCode: $generalServerStatusCode, generalServerErrorId: $generalServerErrorId, generalMessage: $generalMessage, errors: $errors)';
}


}

/// @nodoc
abstract mixin class $ServerErrorCopyWith<$Res>  {
  factory $ServerErrorCopyWith(ServerError value, $Res Function(ServerError) _then) = _$ServerErrorCopyWithImpl;
@useResult
$Res call({
 int? generalServerStatusCode, String? generalServerErrorId, String? generalMessage, List<ServerErrorDetail> errors
});




}
/// @nodoc
class _$ServerErrorCopyWithImpl<$Res>
    implements $ServerErrorCopyWith<$Res> {
  _$ServerErrorCopyWithImpl(this._self, this._then);

  final ServerError _self;
  final $Res Function(ServerError) _then;

/// Create a copy of ServerError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? generalServerStatusCode = freezed,Object? generalServerErrorId = freezed,Object? generalMessage = freezed,Object? errors = null,}) {
  return _then(_self.copyWith(
generalServerStatusCode: freezed == generalServerStatusCode ? _self.generalServerStatusCode : generalServerStatusCode // ignore: cast_nullable_to_non_nullable
as int?,generalServerErrorId: freezed == generalServerErrorId ? _self.generalServerErrorId : generalServerErrorId // ignore: cast_nullable_to_non_nullable
as String?,generalMessage: freezed == generalMessage ? _self.generalMessage : generalMessage // ignore: cast_nullable_to_non_nullable
as String?,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<ServerErrorDetail>,
  ));
}

}


/// @nodoc


class _ServerError implements ServerError {
  const _ServerError({this.generalServerStatusCode, this.generalServerErrorId, this.generalMessage, final  List<ServerErrorDetail> errors = const <ServerErrorDetail>[]}): _errors = errors;
  

@override final  int? generalServerStatusCode;
@override final  String? generalServerErrorId;
@override final  String? generalMessage;
 final  List<ServerErrorDetail> _errors;
@override@JsonKey() List<ServerErrorDetail> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}


/// Create a copy of ServerError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerErrorCopyWith<_ServerError> get copyWith => __$ServerErrorCopyWithImpl<_ServerError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerError&&(identical(other.generalServerStatusCode, generalServerStatusCode) || other.generalServerStatusCode == generalServerStatusCode)&&(identical(other.generalServerErrorId, generalServerErrorId) || other.generalServerErrorId == generalServerErrorId)&&(identical(other.generalMessage, generalMessage) || other.generalMessage == generalMessage)&&const DeepCollectionEquality().equals(other._errors, _errors));
}


@override
int get hashCode => Object.hash(runtimeType,generalServerStatusCode,generalServerErrorId,generalMessage,const DeepCollectionEquality().hash(_errors));

@override
String toString() {
  return 'ServerError(generalServerStatusCode: $generalServerStatusCode, generalServerErrorId: $generalServerErrorId, generalMessage: $generalMessage, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$ServerErrorCopyWith<$Res> implements $ServerErrorCopyWith<$Res> {
  factory _$ServerErrorCopyWith(_ServerError value, $Res Function(_ServerError) _then) = __$ServerErrorCopyWithImpl;
@override @useResult
$Res call({
 int? generalServerStatusCode, String? generalServerErrorId, String? generalMessage, List<ServerErrorDetail> errors
});




}
/// @nodoc
class __$ServerErrorCopyWithImpl<$Res>
    implements _$ServerErrorCopyWith<$Res> {
  __$ServerErrorCopyWithImpl(this._self, this._then);

  final _ServerError _self;
  final $Res Function(_ServerError) _then;

/// Create a copy of ServerError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? generalServerStatusCode = freezed,Object? generalServerErrorId = freezed,Object? generalMessage = freezed,Object? errors = null,}) {
  return _then(_ServerError(
generalServerStatusCode: freezed == generalServerStatusCode ? _self.generalServerStatusCode : generalServerStatusCode // ignore: cast_nullable_to_non_nullable
as int?,generalServerErrorId: freezed == generalServerErrorId ? _self.generalServerErrorId : generalServerErrorId // ignore: cast_nullable_to_non_nullable
as String?,generalMessage: freezed == generalMessage ? _self.generalMessage : generalMessage // ignore: cast_nullable_to_non_nullable
as String?,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<ServerErrorDetail>,
  ));
}


}

// dart format on
