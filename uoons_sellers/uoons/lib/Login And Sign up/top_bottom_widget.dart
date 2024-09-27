import 'package:flutter/material.dart';
import 'dart:math' as math;

class TopWidget extends StatelessWidget {
  final double screenWidth;

  TopWidget({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -35 * math.pi / 180,
      child: Container(
        width: 1.2 * screenWidth,
        height: 1.2 * screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          gradient: const LinearGradient(
            begin: Alignment(-0.2, -0.8),
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(0, 246, 190, 145),
              Color.fromARGB(164, 252, 255, 193),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomWidget extends StatelessWidget {
  final double screenWidth;

  BottomWidget({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.5 * screenWidth,
      height: 1.5 * screenWidth,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(0.6, -1.1),
          end: Alignment(0.7, 0.8),
          colors: [
            Color.fromARGB(0, 246, 190, 145),
            Color.fromARGB(164, 252, 255, 193),
          ],
        ),
      ),
    );
  }
}
