import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_info_entity.freezed.dart';
part 'page_info_entity.g.dart';

@freezed
abstract class PageInfoEntity with _$PageInfoEntity {
  const factory PageInfoEntity(
      {required int currentPage, required int pageSize, required int totalPage}) = _PageInfoEntity;

  factory PageInfoEntity.fromJson(Map<String, dynamic> json) => _$PageInfoEntityFromJson(json);
}
