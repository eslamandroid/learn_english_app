import 'package:flutter/material.dart';
import 'package:learn_english_app/base/base.dart';

class CustomButtonWidget extends StatelessWidget {
  final Widget? child;
  final String? label;
  final double? labelSize;
  final TextStyle? labelStyle;
  final Function()? onClicked;
  final double height;
  final double? width;
  final Color? background;
  final Color? labelColor;
  final Color? disableLabelColor;
  final Color? borderColor;
  final Color? overlayColor;
  final Color? disableColor;
  final bool isBorder;
  final bool isEnable;
  final double borderWidth;
  final Color? shadowColor;
  final Widget? icon;

  final double elevation;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final VisualDensity? visual;
  final MaterialTapTargetSize? tapTargetSize;

  const CustomButtonWidget({
    super.key,
    this.child,
    required this.onClicked,
    this.height = 48.0,
    this.width,
    this.visual,
    this.tapTargetSize,
    this.labelStyle,
    this.padding = EdgeInsets.zero,
    this.label,
    this.labelColor,
    this.disableLabelColor,
    this.disableColor,
    this.labelSize,
    this.isEnable = true,
    this.isBorder = false,
    this.radius = 0.0,
    this.background,
    this.borderColor,
    this.overlayColor,
    this.borderWidth = 0,
    this.icon ,
    this.shadowColor = Colors.transparent,
    this.elevation = 0,

  });

  @override
  Widget build(BuildContext context) {
    return isBorder
        ? Container(
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: context.colorScheme.primary, width: 2),
          ),
          child: _button(context),
        )
        : _button(context);
  }

  Widget _button(BuildContext context) => ElevatedButton(
    onPressed: isEnable ? onClicked : null,
    style: ElevatedButton.styleFrom(
      backgroundColor: background ?? context.colorScheme.primary,
      surfaceTintColor: background ?? context.colorScheme.primary,
      disabledBackgroundColor: disableColor ?? context.currentThemes.disabledColor,
      elevation: elevation,
      visualDensity: visual,
      padding: padding,
      overlayColor: overlayColor ?? Colors.white,
      splashFactory: InkRipple.splashFactory,
      tapTargetSize: tapTargetSize,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(width: borderWidth, color: borderColor ?? context.colorScheme.primary),
      ),
      minimumSize: Size(width ?? double.infinity, height),
      maximumSize: Size(width ?? double.infinity, height),
    ),
    child:
        (label != null)
            ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if(icon!=null)
                ...[
                  icon!,
                  const SizedBox(width: 10,)
                ],
                Text(
                  label!,
                  style:
                      labelStyle ??
                      context.textTheme.titleMedium?.copyWith(
                        color:
                            (isEnable)
                                ? labelColor ?? context.colorScheme.onPrimary
                                : disableLabelColor ?? Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: labelSize,
                      ),
                ),
              ],
            )
            : child,
  );
}
