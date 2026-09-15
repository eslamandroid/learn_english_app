import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? radius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    required this.height,
    this.width,
    this.radius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE6E6E6),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}
