import 'package:flutter/material.dart';
import 'dart:math' as math;

class SteeringWheelPainter extends CustomPainter {
  final double headingAngle;
  SteeringWheelPainter({required this.headingAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    final linePaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, linePaint);
    double extend = 8.0;
    canvas.drawLine(Offset(center.dx - radius - extend, center.dy), Offset(center.dx + radius + extend, center.dy), linePaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius - extend), Offset(center.dx, center.dy + radius + extend), linePaint);

    final dx = center.dx + radius * math.cos(headingAngle);
    final dy = center.dy + radius * math.sin(headingAngle);
    
    canvas.drawLine(center, Offset(dx, dy), Paint()..color = Colors.cyanAccent.withValues(alpha: 0.8)..style = PaintingStyle.stroke..strokeWidth = 2.0);
    canvas.drawCircle(Offset(dx, dy), 3.5, Paint()..color = Colors.cyanAccent);
  }

  @override
  bool shouldRepaint(covariant SteeringWheelPainter oldDelegate) => oldDelegate.headingAngle != headingAngle;
}