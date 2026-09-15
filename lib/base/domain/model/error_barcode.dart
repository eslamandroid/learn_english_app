import 'package:json_annotation/json_annotation.dart';

part 'error_barcode.g.dart';

@JsonSerializable()
class ErrorCode {
  final String barcode;
  final int qty;

  ErrorCode(this.barcode, this.qty);

  factory ErrorCode.fromFirestore(Map<String, dynamic> data) {
    return ErrorCode(data['barCode'] as String? ?? '', data['qty'] as int? ?? 1);
  }

  factory ErrorCode.fromJson(Map<String, dynamic> json) =>
      _$ErrorCodeFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorCodeToJson(this);

  @override
  String toString() =>
      'ErrorCode(barcode: $barcode, qty: $qty)';
}
