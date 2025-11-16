import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerField extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  const ShimmerField({
    super.key,
    this.height = 24,
    this.width = double.infinity,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}
