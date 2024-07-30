import 'package:flutter/material.dart';
import 'dart:ui';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Gradient gradient;
  final EdgeInsetsGeometry padding;
  final Alignment alignment;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.borderRadius = 0,
    this.blur = 10,
    required this.gradient,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
          alignment: alignment,
          child: child,
        ),
      ),
    );
  }
}