import '../../domain/entities/phonetic_table_item.dart';

class PhoneticTableItemModel extends PhoneticTableItem {
  const PhoneticTableItemModel({
    required super.id,
    required super.sectionId,
    required super.sortOrder,
    required super.title,
    required super.value,
  });

  factory PhoneticTableItemModel.fromMap(Map<String, Object?> map) {
    return PhoneticTableItemModel(
      id: map['id'] as int,
      sectionId: map['section_id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      value: map['value'] as String? ?? '',
    );
  }
}
