import 'package:flutter/material.dart';

import '../../core/theme/bayan_colors.dart';

enum CefrLevel {
  a1('a1', 'A1', 'Beginner', BayanColors.a1Color),
  a2('a2', 'A2', 'Elementary', BayanColors.a2Color),
  b1('b1', 'B1', 'Intermediate', BayanColors.b1Color),
  b2('b2', 'B2', 'Upper-Intermediate', BayanColors.b2Color),
  c1('c1', 'C1', 'Advanced', BayanColors.c1Color),
  c2('c2', 'C2', 'Proficient', BayanColors.c2Color);

  final String key;
  final String label;
  final String description;
  final Color color;

  const CefrLevel(this.key, this.label, this.description, this.color);

  int get id => index + 1;

  static CefrLevel fromKey(String? key) => CefrLevel.values.firstWhere(
        (l) => l.key == key,
        orElse: () => CefrLevel.a1,
      );

  static CefrLevel fromId(int id) =>
      (id >= 1 && id <= CefrLevel.values.length)
          ? CefrLevel.values[id - 1]
          : CefrLevel.a1;
}
