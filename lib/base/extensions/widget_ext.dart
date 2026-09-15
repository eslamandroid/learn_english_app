
import 'package:flutter/material.dart';

extension ColumnEx on Column {
  Widget wrap({double padding = 0.0, double margin = 0.0}) {
    final reversedChildren = children
        .map((e) => Container(
      padding: EdgeInsets.all(padding),
      margin: EdgeInsets.all(margin),
      child: e,
    ))
        .toList();

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      textDirection: textDirection,
      children: reversedChildren,
    );
  }

  Widget wrapOuter({double padding = 0.0, double margin = 0.0}) {
    return Container(
      padding: EdgeInsets.all(padding),
      margin: EdgeInsets.all(margin),
      child: this,
    );
  }

  Widget wrapOuterEdgeInsets({EdgeInsetsGeometry padding = EdgeInsets.zero, EdgeInsetsGeometry margin = EdgeInsets.zero}) {
    return Container(
      padding: padding,
      margin: margin,
      child: this,
    );
  }
}

extension ListExt on ListView {
  Widget wrapOuter({double padding = 0.0, double margin = 0.0}) {
    return Container(
      padding: EdgeInsets.all(padding),
      margin: EdgeInsets.all(margin),
      child: this,
    );
  }

  Widget wrapPadding({EdgeInsetsGeometry padding = EdgeInsets.zero}) {
    return Padding(
      padding: padding,
      child: this,
    );
  }

  Widget wrapOuterEdgeInsets({EdgeInsetsGeometry padding = EdgeInsets.zero, EdgeInsetsGeometry margin = EdgeInsets.zero}) {
    return Container(
      padding: padding,
      margin: margin,
      child: this,
    );
  }
}

extension SingleScrollExt on SingleChildScrollView {
  Widget wrapOuterEdgeInsets({EdgeInsetsGeometry padding = EdgeInsets.zero, EdgeInsetsGeometry margin = EdgeInsets.zero}) {
    return Container(
      padding: padding,
      margin: margin,
      child: this,
    );
  }
}

extension ListWidgetExt on List<Widget> {
  List<Widget> separate(double space, {bool fromFirst = false}) => length <= 1
      ? this
      : sublist(1).fold([
    if (fromFirst)
      SizedBox(
        height: space,
        width: space,
      ),
    first
  ], (previousValue, element) => [...previousValue, SizedBox(height: space, width: space), element]);

  Widget padding(double all) => Padding(
    padding: EdgeInsets.all(all),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: this,
    ),
  );

  Widget paddingTBLE(
      {double? top,
        double? bottom,
        double? left,
        double? right,
        MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
        CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) =>
      Padding(
          padding: EdgeInsets.only(top: top ?? 0, bottom: bottom ?? 0, left: left ?? 0, right: right ?? 0),
          child: Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: this,
          ));
}

extension WidgetExt on Widget {
  Widget padding(double all) => Padding(padding: EdgeInsets.all(all), child: this);

  Widget paddingTBLE({double? top, double? bottom, double? left, double? right}) =>
      Padding(padding: EdgeInsets.only(top: top ?? 0, bottom: bottom ?? 0, left: left ?? 0, right: right ?? 0), child: this);

  Widget paddingTBSE({double? top, double? bottom, double? start, double? end}) => Padding(
      padding: EdgeInsetsDirectional.only(top: top ?? 0, bottom: bottom ?? 0, start: start ?? 0, end: end ?? 0), child: this);

  Widget paddingSymmetric({
    double? horizontal,
    double? vertical,
  }) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: horizontal ?? 0, vertical: vertical ?? 0), child: this);

  SliverPadding paddingSilverTBLE({double? top, double? bottom, double? left, double? right}) => SliverPadding(
      padding: EdgeInsets.only(top: top ?? 0, bottom: bottom ?? 0, left: left ?? 0, right: right ?? 0), sliver: this);
}




