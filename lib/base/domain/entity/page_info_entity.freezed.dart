// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_info_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PageInfoEntity {

 int get currentPage; int get pageSize; int get totalPage;
/// Create a copy of PageInfoEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageInfoEntityCopyWith<PageInfoEntity> get copyWith => _$PageInfoEntityCopyWithImpl<PageInfoEntity>(this as PageInfoEntity, _$identity);

  /// Serializes this PageInfoEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageInfoEntity&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalPage, totalPage) || other.totalPage == totalPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPage,pageSize,totalPage);

@override
String toString() {
  return 'PageInfoEntity(currentPage: $currentPage, pageSize: $pageSize, totalPage: $totalPage)';
}


}

/// @nodoc
abstract mixin class $PageInfoEntityCopyWith<$Res>  {
  factory $PageInfoEntityCopyWith(PageInfoEntity value, $Res Function(PageInfoEntity) _then) = _$PageInfoEntityCopyWithImpl;
@useResult
$Res call({
 int currentPage, int pageSize, int totalPage
});




}
/// @nodoc
class _$PageInfoEntityCopyWithImpl<$Res>
    implements $PageInfoEntityCopyWith<$Res> {
  _$PageInfoEntityCopyWithImpl(this._self, this._then);

  final PageInfoEntity _self;
  final $Res Function(PageInfoEntity) _then;

/// Create a copy of PageInfoEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPage = null,Object? pageSize = null,Object? totalPage = null,}) {
  return _then(_self.copyWith(
currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalPage: null == totalPage ? _self.totalPage : totalPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _PageInfoEntity implements PageInfoEntity {
  const _PageInfoEntity({required this.currentPage, required this.pageSize, required this.totalPage});
  factory _PageInfoEntity.fromJson(Map<String, dynamic> json) => _$PageInfoEntityFromJson(json);

@override final  int currentPage;
@override final  int pageSize;
@override final  int totalPage;

/// Create a copy of PageInfoEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PageInfoEntityCopyWith<_PageInfoEntity> get copyWith => __$PageInfoEntityCopyWithImpl<_PageInfoEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PageInfoEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PageInfoEntity&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalPage, totalPage) || other.totalPage == totalPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPage,pageSize,totalPage);

@override
String toString() {
  return 'PageInfoEntity(currentPage: $currentPage, pageSize: $pageSize, totalPage: $totalPage)';
}


}

/// @nodoc
abstract mixin class _$PageInfoEntityCopyWith<$Res> implements $PageInfoEntityCopyWith<$Res> {
  factory _$PageInfoEntityCopyWith(_PageInfoEntity value, $Res Function(_PageInfoEntity) _then) = __$PageInfoEntityCopyWithImpl;
@override @useResult
$Res call({
 int currentPage, int pageSize, int totalPage
});




}
/// @nodoc
class __$PageInfoEntityCopyWithImpl<$Res>
    implements _$PageInfoEntityCopyWith<$Res> {
  __$PageInfoEntityCopyWithImpl(this._self, this._then);

  final _PageInfoEntity _self;
  final $Res Function(_PageInfoEntity) _then;

/// Create a copy of PageInfoEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPage = null,Object? pageSize = null,Object? totalPage = null,}) {
  return _then(_PageInfoEntity(
currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalPage: null == totalPage ? _self.totalPage : totalPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
