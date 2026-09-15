// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_barcode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorCode _$ErrorCodeFromJson(Map<String, dynamic> json) =>
    ErrorCode(json['barcode'] as String, (json['qty'] as num).toInt());

Map<String, dynamic> _$ErrorCodeToJson(ErrorCode instance) => <String, dynamic>{
  'barcode': instance.barcode,
  'qty': instance.qty,
};
