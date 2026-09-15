import 'package:flutter/material.dart';
import 'package:learn_english_app/base/base.dart';

class StatusWidget extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final bool isVisibility;
  final bool fromStart;
  final bool value;
  final Color? unCheckedBackgroundColor;
  final Color? checkedColor;
  final Color? checkedBackgroundColor;
  final Color? checkedBorderColor;
  final double checkedBorderRadius;
  final double checkedBorderWidth;
  final void Function(bool value) onChange;

  const StatusWidget(
      {super.key,
      this.isVisibility = false,
      this.fromStart = false,
      required this.title,
      this.titleStyle,
      this.unCheckedBackgroundColor,
      this.checkedColor,
      this.checkedBorderRadius = 4,
      this.checkedBorderWidth = 1,
      this.checkedBorderColor,
      this.checkedBackgroundColor,
      required this.onChange,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if(fromStart)
          ...[
            GestureDetector(
              onTap: () {
                onChange(!value);
              },
              child: Container(
                width: 21,
                height: 21,
                decoration: BoxDecoration(
                  color: value
                      ? checkedBackgroundColor ?? context.colorScheme.primary
                      : unCheckedBackgroundColor ?? context.colorScheme.surface,
                  border: Border.all(
                      color: value
                          ? Colors.transparent
                          : checkedBorderColor ?? context.colorScheme.outline,
                      width: checkedBorderWidth),
                  borderRadius: BorderRadius.circular(checkedBorderRadius),
                ),
                child: value
                    ? Icon(
                  Icons.check,
                  size: 18,
                  color: checkedColor ?? context.colorScheme.primary,
                )
                    : null,
              ),
            ),
            SizedBox(width: 8),
          ],

        Expanded(
          child: Text(
            title,
            style: titleStyle ?? context.textTheme.bodySmall,
          ),
        ),
        SizedBox(width: 8),
        if(!fromStart)
        GestureDetector(
          onTap: () {
            onChange(!value);
          },
          child: Container(
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              color: value
                  ? checkedBackgroundColor ?? context.colorScheme.primary
                  : unCheckedBackgroundColor ?? context.colorScheme.surface,
              border: Border.all(
                  color: value
                      ? Colors.transparent
                      : checkedBorderColor ?? context.colorScheme.outline,
                  width: checkedBorderWidth),
              borderRadius: BorderRadius.circular(checkedBorderRadius),
            ),
            child: value
                ? Icon(
                    Icons.check,
                    size: 18,
                    color: checkedColor ?? context.colorScheme.primary,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
