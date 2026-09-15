import 'dart:convert';

import '../../domain/entities/phonetic_example.dart';
import '../../domain/entities/phonetic_section.dart';
import '../../domain/entities/phonetic_table_item.dart';

class PhoneticSectionModel extends PhoneticSection {
  const PhoneticSectionModel({
    required super.id,
    required super.topicId,
    required super.accent,
    required super.sortOrder,
    required super.type,
    super.superType,
    super.title,
    super.titleAr,
    super.body,
    super.bodyAr,
    super.image,
    super.image2,
    super.sound,
    super.sound2,
    super.highlight,
    super.tableItems,
    super.examples,
  });

  factory PhoneticSectionModel.fromMap(Map<String, Object?> map) {
    return PhoneticSectionModel(
      id: map['id'] as int,
      topicId: map['topic_id'] as int,
      accent: map['accent'] as String,
      sortOrder: map['sort_order'] as int? ?? 0,
      type: map['type'] as String,
      superType: map['super_type'] as String?,
      title: map['title'] as String?,
      titleAr: map['title_ar'] as String?,
      body: map['body'] as String?,
      bodyAr: map['body_ar'] as String?,
      image: _emptyToNull(map['image'] as String?),
      image2: _emptyToNull(map['image2'] as String?),
      sound: _emptyToNull(map['sound'] as String?),
      sound2: _emptyToNull(map['sound2'] as String?),
      highlight: _parseHighlight(map['highlight'] as String?),
    );
  }

  PhoneticSectionModel copyWithChildren({
    List<PhoneticTableItem>? tableItems,
    List<PhoneticExample>? examples,
  }) {
    return PhoneticSectionModel(
      id: id,
      topicId: topicId,
      accent: accent,
      sortOrder: sortOrder,
      type: type,
      superType: superType,
      title: title,
      titleAr: titleAr,
      body: body,
      bodyAr: bodyAr,
      image: image,
      image2: image2,
      sound: sound,
      sound2: sound2,
      highlight: highlight,
      tableItems: tableItems ?? this.tableItems,
      examples: examples ?? this.examples,
    );
  }

  static String? _emptyToNull(String? value) =>
      (value == null || value.isEmpty) ? null : value;

  static List<String> _parseHighlight(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // Not JSON — fall back to a comma-separated string.
    }
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
