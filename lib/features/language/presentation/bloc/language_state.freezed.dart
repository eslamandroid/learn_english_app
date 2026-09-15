// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'language_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LanguageState {

 bool? get loading; bool? get progress; LanguageModel? get currentLanguage; List<LanguageModel>? get supportedLanguages; bool? get success; String? get screenId; AppException? get appException;
/// Create a copy of LanguageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LanguageStateCopyWith<LanguageState> get copyWith => _$LanguageStateCopyWithImpl<LanguageState>(this as LanguageState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LanguageState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.currentLanguage, currentLanguage) || other.currentLanguage == currentLanguage)&&const DeepCollectionEquality().equals(other.supportedLanguages, supportedLanguages)&&(identical(other.success, success) || other.success == success)&&(identical(other.screenId, screenId) || other.screenId == screenId)&&(identical(other.appException, appException) || other.appException == appException));
}


@override
int get hashCode => Object.hash(runtimeType,loading,progress,currentLanguage,const DeepCollectionEquality().hash(supportedLanguages),success,screenId,appException);

@override
String toString() {
  return 'LanguageState(loading: $loading, progress: $progress, currentLanguage: $currentLanguage, supportedLanguages: $supportedLanguages, success: $success, screenId: $screenId, appException: $appException)';
}


}

/// @nodoc
abstract mixin class $LanguageStateCopyWith<$Res>  {
  factory $LanguageStateCopyWith(LanguageState value, $Res Function(LanguageState) _then) = _$LanguageStateCopyWithImpl;
@useResult
$Res call({
 bool? loading, bool? progress, LanguageModel? currentLanguage, List<LanguageModel>? supportedLanguages, bool? success, String? screenId, AppException? appException
});




}
/// @nodoc
class _$LanguageStateCopyWithImpl<$Res>
    implements $LanguageStateCopyWith<$Res> {
  _$LanguageStateCopyWithImpl(this._self, this._then);

  final LanguageState _self;
  final $Res Function(LanguageState) _then;

/// Create a copy of LanguageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = freezed,Object? progress = freezed,Object? currentLanguage = freezed,Object? supportedLanguages = freezed,Object? success = freezed,Object? screenId = freezed,Object? appException = freezed,}) {
  return _then(_self.copyWith(
loading: freezed == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as bool?,currentLanguage: freezed == currentLanguage ? _self.currentLanguage : currentLanguage // ignore: cast_nullable_to_non_nullable
as LanguageModel?,supportedLanguages: freezed == supportedLanguages ? _self.supportedLanguages : supportedLanguages // ignore: cast_nullable_to_non_nullable
as List<LanguageModel>?,success: freezed == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool?,screenId: freezed == screenId ? _self.screenId : screenId // ignore: cast_nullable_to_non_nullable
as String?,appException: freezed == appException ? _self.appException : appException // ignore: cast_nullable_to_non_nullable
as AppException?,
  ));
}

}


/// @nodoc


class _LanguageState implements LanguageState {
  const _LanguageState({this.loading, this.progress, this.currentLanguage, final  List<LanguageModel>? supportedLanguages, this.success, this.screenId, this.appException}): _supportedLanguages = supportedLanguages;
  

@override final  bool? loading;
@override final  bool? progress;
@override final  LanguageModel? currentLanguage;
 final  List<LanguageModel>? _supportedLanguages;
@override List<LanguageModel>? get supportedLanguages {
  final value = _supportedLanguages;
  if (value == null) return null;
  if (_supportedLanguages is EqualUnmodifiableListView) return _supportedLanguages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  bool? success;
@override final  String? screenId;
@override final  AppException? appException;

/// Create a copy of LanguageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LanguageStateCopyWith<_LanguageState> get copyWith => __$LanguageStateCopyWithImpl<_LanguageState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LanguageState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.currentLanguage, currentLanguage) || other.currentLanguage == currentLanguage)&&const DeepCollectionEquality().equals(other._supportedLanguages, _supportedLanguages)&&(identical(other.success, success) || other.success == success)&&(identical(other.screenId, screenId) || other.screenId == screenId)&&(identical(other.appException, appException) || other.appException == appException));
}


@override
int get hashCode => Object.hash(runtimeType,loading,progress,currentLanguage,const DeepCollectionEquality().hash(_supportedLanguages),success,screenId,appException);

@override
String toString() {
  return 'LanguageState(loading: $loading, progress: $progress, currentLanguage: $currentLanguage, supportedLanguages: $supportedLanguages, success: $success, screenId: $screenId, appException: $appException)';
}


}

/// @nodoc
abstract mixin class _$LanguageStateCopyWith<$Res> implements $LanguageStateCopyWith<$Res> {
  factory _$LanguageStateCopyWith(_LanguageState value, $Res Function(_LanguageState) _then) = __$LanguageStateCopyWithImpl;
@override @useResult
$Res call({
 bool? loading, bool? progress, LanguageModel? currentLanguage, List<LanguageModel>? supportedLanguages, bool? success, String? screenId, AppException? appException
});




}
/// @nodoc
class __$LanguageStateCopyWithImpl<$Res>
    implements _$LanguageStateCopyWith<$Res> {
  __$LanguageStateCopyWithImpl(this._self, this._then);

  final _LanguageState _self;
  final $Res Function(_LanguageState) _then;

/// Create a copy of LanguageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = freezed,Object? progress = freezed,Object? currentLanguage = freezed,Object? supportedLanguages = freezed,Object? success = freezed,Object? screenId = freezed,Object? appException = freezed,}) {
  return _then(_LanguageState(
loading: freezed == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as bool?,currentLanguage: freezed == currentLanguage ? _self.currentLanguage : currentLanguage // ignore: cast_nullable_to_non_nullable
as LanguageModel?,supportedLanguages: freezed == supportedLanguages ? _self._supportedLanguages : supportedLanguages // ignore: cast_nullable_to_non_nullable
as List<LanguageModel>?,success: freezed == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool?,screenId: freezed == screenId ? _self.screenId : screenId // ignore: cast_nullable_to_non_nullable
as String?,appException: freezed == appException ? _self.appException : appException // ignore: cast_nullable_to_non_nullable
as AppException?,
  ));
}


}

// dart format on
