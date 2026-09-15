// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PageInfoEntity _$PageInfoEntityFromJson(Map<String, dynamic> json) =>
    _PageInfoEntity(
      currentPage: (json['currentPage'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPage: (json['totalPage'] as num).toInt(),
    );

Map<String, dynamic> _$PageInfoEntityToJson(_PageInfoEntity instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'pageSize': instance.pageSize,
      'totalPage': instance.totalPage,
    };
