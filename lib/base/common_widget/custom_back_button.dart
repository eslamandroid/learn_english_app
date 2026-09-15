import 'dart:io';
import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final void Function() onClicked;
  final Widget? icon;
  final bool defaultIosIcon;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final double size;
  final Color? color;

  const CustomBackButton({super.key, required this.onClicked, this.icon, this.color, this.defaultIosIcon = false, this.padding,this.decoration,this.size = 24});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onClicked,
        child: Container(
          padding: padding?? EdgeInsets.all(8),
          height: size,
          width: size,
          decoration: decoration??BoxDecoration(
            color: Colors.transparent,
          ),
           child: icon ??
              Icon(
                ((Platform.isIOS || defaultIosIcon) ? Icons.arrow_back_ios_new_outlined : Icons.arrow_back_rounded),
                color: color ?? Colors.black87,
              ),
        ));
  }
}

class CustomCloseButton extends StatelessWidget {
  final void Function() onClicked;
  final Color? color;
  final double? size;

  const CustomCloseButton({super.key, required this.onClicked, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onClicked,
        child: Icon(
          Icons.close,
          size: size,
          color: color ?? Colors.black87,
        ));
  }
}
