import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatelessWidget {
  final AnimationController controller;

  const AnimatedGradientBackground({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A237E),
                Color(0xFF0D47A1),
                Color(0xFF01579B),
                Color(0xFF0288D1),
              ],
              stops: [
                0,
                0.3 + (0.2 * controller.value),
                0.6 + (0.2 * controller.value),
                1,
              ],
            ),
          ),
        );
      },
    );
  }
}