import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

extension EmptySpace on num {
  SizedBox get ph => SizedBox(height: toDouble());

  SizedBox get pw => SizedBox(width: toDouble());
}

extension EmptySpaceSliver on num {
  SliverToBoxAdapter get phSliver => SliverToBoxAdapter(child: SizedBox(height: toDouble()));

  SliverToBoxAdapter get pwSliver => SliverToBoxAdapter(child: SizedBox(width: toDouble()));
}

extension IntegerExt on int {
  int calculateItemsBasedCrossing(int crossAxisCount) {
    if (this % crossAxisCount == 0) {
      return this ~/ crossAxisCount;
    } else {
      return (this ~/ crossAxisCount) + 1;
    }
  }


  String get encodeToBase64 {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(toString());
     return encoded;
  }

}

extension DoubleExt on double {
  String get toFormatPrice => intl.NumberFormat('#,##0.00', 'en_US').format(this);

  String get toPrice => intl.NumberFormat('#,##0', 'en_US').format(this);

  double fromPercent(double percent) {
    return this * percent;
  }

  String get toRate => this> 0 ?intl.NumberFormat('#.0','en_US').format(this * 5 / 100):"0.0";

  int toAlpha() => (this * 255).round();

  double? toPrecision(int n) => double.tryParse(toStringAsFixed(n));


}

extension DoubleListExt on List<double> {
  double sumList() {
    double total = 0;
    forEach((element) {
      total = total + element;
    });
    return total;
  }
}
