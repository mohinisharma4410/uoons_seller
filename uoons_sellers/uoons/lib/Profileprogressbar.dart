import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProfileProgress extends StatelessWidget {
  final bool personalDetailsCompleted;
  final bool manageStoresCompleted;
  final bool kycUpdateCompleted;
  final bool bankDetailsCompleted;

  ProfileProgress({
    required this.personalDetailsCompleted,
    required this.manageStoresCompleted,
    required this.kycUpdateCompleted,
    required this.bankDetailsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate completion percentage based on the completion status of each profile section
    double totalSections = 4; // Total number of profile sections
    double completedSections = 0;

    if (personalDetailsCompleted) completedSections++;
    if (manageStoresCompleted) completedSections++;
    if (kycUpdateCompleted) completedSections++;
    if (bankDetailsCompleted) completedSections++;

    double completionPercentage = completedSections / totalSections;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomCircularPercentIndicator(
            radius: 80.0,
            lineWidth: 30.0,
            percent: completionPercentage,
            gradientColors:     [
              Color.fromARGB(255, 253, 64, 47),
              Color.fromARGB(255, 252, 197, 180),
            ],
            backgroundColor: const Color.fromARGB(255, 203, 203, 203)!,
            center: Text(
              "${(completionPercentage * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class CustomCircularPercentIndicator extends StatelessWidget {
  final double radius;
  final double lineWidth;
  final double percent;
  final List<Color> gradientColors;
  final Color backgroundColor;
  final Widget center;

  CustomCircularPercentIndicator({
    required this.radius,
    required this.lineWidth,
    required this.percent,
    required this.gradientColors,
    required this.backgroundColor,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(radius * 2, radius * 2),
            painter: GradientArcPainter(
              lineWidth: lineWidth,
              percent: percent,
              gradientColors: gradientColors,
              backgroundColor: backgroundColor,
            ),
          ),
          center,
        ],
      ),
    );
  }
}

class GradientArcPainter extends CustomPainter {
  final double lineWidth;
  final double percent;
  final List<Color> gradientColors;
  final Color backgroundColor;

  GradientArcPainter({
    required this.lineWidth,
    required this.percent,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    Offset center = Offset(size.width / 2, size.height / 2);
    Rect rect = Rect.fromCircle(center: center, radius: radius);

    // Draw the background circle
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Create the gradient
    Paint gradientPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2, // 12 o'clock position
        endAngle: pi * (2 * percent) - pi / 2, // Adjusted end angle
        colors: gradientColors,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    // Draw the gradient arc
    double sweepAngle = 2 * pi * percent;
    canvas.drawArc(rect, -pi / 2, sweepAngle, false, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
