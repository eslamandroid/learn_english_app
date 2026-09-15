import 'package:flutter/material.dart';

import '../../core/theme/bayan_colors.dart';

/// Plain placeholder block for loading skeletons.
class SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.height,
    required this.radius,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
